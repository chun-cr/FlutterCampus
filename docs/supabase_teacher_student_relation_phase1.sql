-- 请在 Supabase SQL Editor 中执行
-- 目的：
-- 1. 保留现有 auth.users / public.users 账号，不删除、不重建账号
-- 2. 建立“学生 -> 班级 -> 班主任”和“教师 -> 本学期课程 -> 授课班级”的真实关系
-- 3. 给后续 Flutter 代码改造补齐必要字段
-- 4. 本阶段暂不启用严格 RLS，避免旧版 App 在代码未改前直接失效
--
-- 如果你当前的 public.students / public.teacher_profiles 里存在手工插入的虚拟数据，
-- 请先执行 docs/supabase_user_relation_audit.sql 做审计，再回来执行本脚本。

begin;

-- ============================================================================
-- 0. 先核对你当前已有账号
-- 建议先单独执行下面这条查询，确认老师邮箱、学生学号后，再执行整个脚本
-- select id, name, email, phone, type, student_id, department
-- from public.users
-- order by created_at;
-- ============================================================================

-- ============================================================================
-- 1. 补充业务关系字段
-- ============================================================================

alter table public.leave_applications
  add column if not exists class_id uuid references public.classes(id);

alter table public.grades
  add column if not exists class_id uuid references public.classes(id);

alter table public.grades
  add column if not exists teacher_schedule_id uuid references public.teacher_schedules(id);

create index if not exists idx_leave_applications_student_id
  on public.leave_applications(student_id);

create index if not exists idx_leave_applications_class_id
  on public.leave_applications(class_id);

create index if not exists idx_leave_applications_status
  on public.leave_applications(status);

create index if not exists idx_grades_user_id
  on public.grades(user_id);

create index if not exists idx_grades_class_id
  on public.grades(class_id);

create index if not exists idx_grades_teacher_schedule_id
  on public.grades(teacher_schedule_id);

create unique index if not exists idx_grades_unique_student_schedule
  on public.grades(user_id, teacher_schedule_id)
  where teacher_schedule_id is not null;

comment on column public.leave_applications.class_id is '学生提交请假时所属班级，审批权限按 classes.head_teacher_id 判断';
comment on column public.grades.class_id is '该条成绩对应的学生班级';
comment on column public.grades.teacher_schedule_id is '该条成绩对应的教师授课任务';

-- ============================================================================
-- 2. 先按已有学生档案自动回填旧业务数据
-- 如果 students / classes 还没建完整，后面的模板会补齐，再次回填一遍
-- ============================================================================

update public.leave_applications la
set class_id = s.class_id
from public.students s
where la.student_id = s.id
  and la.class_id is null;

update public.leave_applications la
set class_name = c.class_name
from public.classes c
where la.class_id = c.id
  and (la.class_name is null or la.class_name <> c.class_name);

update public.grades g
set class_id = s.class_id
from public.students s
where g.user_id = s.id
  and g.class_id is null;

update public.grades g
set teacher_schedule_id = ts.id
from public.teacher_schedules ts
where g.teacher_schedule_id is null
  and g.teacher_id = ts.teacher_id
  and g.semester = ts.semester
  and g.course_name = ts.course_name
  and g.class_id is not null
  and g.class_id = any(ts.class_ids);

-- ============================================================================
-- 3. 绑定你当前这 1 个老师 + 2 个学生的真实关系
--
-- 执行前必须替换下面这些占位符：
-- __TEACHER_EMAIL__
-- __TEACHER_NO__
-- __TEACHER_DEPARTMENT__
-- __MANAGED_CLASS_NAME__
-- __MANAGED_CLASS_GRADE__
-- __MANAGED_CLASS_MAJOR__
-- __OTHER_CLASS_NAME__
-- __OTHER_CLASS_GRADE__
-- __OTHER_CLASS_MAJOR__
-- __STUDENT_1_NO__
-- __STUDENT_1_NAME__
-- __STUDENT_2_NO__
-- __STUDENT_2_NAME__
-- __SEMESTER__
-- __COURSE_NAME__
-- __COURSE_CODE__
-- __COURSE_LOCATION__
--
-- 设计说明：
-- 1. 第一个学生会被分到“当前老师真正负责的班”
-- 2. 第二个学生会被分到“另一个班”，当前老师不会自动获得这个班的审批权
-- 3. 当前老师只会拥有“受管班级”的授课任务，因此不能给第二个学生录成绩
-- 4. 如果你后续还有更多课程，复制 teacher_schedules 的插入段即可
-- ============================================================================

do $$
declare
  v_teacher_email text := '__TEACHER_EMAIL__';
  v_teacher_no text := '__TEACHER_NO__';
  v_teacher_department text := '__TEACHER_DEPARTMENT__';

  v_managed_class_name text := '__MANAGED_CLASS_NAME__';
  v_managed_class_grade text := '__MANAGED_CLASS_GRADE__';
  v_managed_class_major text := '__MANAGED_CLASS_MAJOR__';

  v_other_class_name text := '__OTHER_CLASS_NAME__';
  v_other_class_grade text := '__OTHER_CLASS_GRADE__';
  v_other_class_major text := '__OTHER_CLASS_MAJOR__';

  v_student_1_no text := '__STUDENT_1_NO__';
  v_student_1_name text := '__STUDENT_1_NAME__';
  v_student_2_no text := '__STUDENT_2_NO__';
  v_student_2_name text := '__STUDENT_2_NAME__';

  v_semester text := '__SEMESTER__';
  v_course_name text := '__COURSE_NAME__';
  v_course_code text := '__COURSE_CODE__';
  v_course_location text := '__COURSE_LOCATION__';

  v_teacher_id uuid;
  v_student_1_id uuid;
  v_student_2_id uuid;
  v_managed_class_id uuid;
  v_other_class_id uuid;
begin
  select u.id
  into v_teacher_id
  from public.users u
  where lower(coalesce(u.type, '')) like '%teacher%'
    and u.email = v_teacher_email
  limit 1;

  if v_teacher_id is null then
    raise exception '未找到教师账号，请检查邮箱：% ', v_teacher_email;
  end if;

  select u.id
  into v_student_1_id
  from public.users u
  where lower(coalesce(u.type, '')) like '%student%'
    and u.student_id = v_student_1_no
  limit 1;

  if v_student_1_id is null then
    raise exception '未找到学生 1 账号，请检查学号：% ', v_student_1_no;
  end if;

  select u.id
  into v_student_2_id
  from public.users u
  where lower(coalesce(u.type, '')) like '%student%'
    and u.student_id = v_student_2_no
  limit 1;

  if v_student_2_id is null then
    raise exception '未找到学生 2 账号，请检查学号：% ', v_student_2_no;
  end if;

  insert into public.teacher_profiles (
    id,
    teacher_no,
    department
  )
  values (
    v_teacher_id,
    v_teacher_no,
    v_teacher_department
  )
  on conflict (id) do update
  set teacher_no = excluded.teacher_no,
      department = excluded.department;

  insert into public.classes (
    class_name,
    grade,
    major,
    department,
    head_teacher_id
  )
  values (
    v_managed_class_name,
    v_managed_class_grade,
    v_managed_class_major,
    v_teacher_department,
    v_teacher_id
  )
  on conflict (class_name) do update
  set grade = excluded.grade,
      major = excluded.major,
      department = excluded.department,
      head_teacher_id = excluded.head_teacher_id
  returning id into v_managed_class_id;

  insert into public.classes (
    class_name,
    grade,
    major,
    department,
    head_teacher_id
  )
  values (
    v_other_class_name,
    v_other_class_grade,
    v_other_class_major,
    v_teacher_department,
    null
  )
  on conflict (class_name) do update
  set grade = excluded.grade,
      major = excluded.major,
      department = excluded.department
  returning id into v_other_class_id;

  insert into public.students (
    id,
    student_no,
    name,
    class_id,
    phone,
    email,
    status
  )
  select
    u.id,
    coalesce(nullif(u.student_id, ''), v_student_1_no),
    coalesce(nullif(u.name, ''), v_student_1_name),
    v_managed_class_id,
    u.phone,
    u.email,
    'active'
  from public.users u
  where u.id = v_student_1_id
  on conflict (id) do update
  set student_no = excluded.student_no,
      name = excluded.name,
      class_id = excluded.class_id,
      phone = excluded.phone,
      email = excluded.email,
      status = excluded.status;

  insert into public.students (
    id,
    student_no,
    name,
    class_id,
    phone,
    email,
    status
  )
  select
    u.id,
    coalesce(nullif(u.student_id, ''), v_student_2_no),
    coalesce(nullif(u.name, ''), v_student_2_name),
    v_other_class_id,
    u.phone,
    u.email,
    'active'
  from public.users u
  where u.id = v_student_2_id
  on conflict (id) do update
  set student_no = excluded.student_no,
      name = excluded.name,
      class_id = excluded.class_id,
      phone = excluded.phone,
      email = excluded.email,
      status = excluded.status;

  if not exists (
    select 1
    from public.teacher_schedules ts
    where ts.teacher_id = v_teacher_id
      and ts.semester = v_semester
      and ts.course_name = v_course_name
      and ts.class_ids = array[v_managed_class_id]
  ) then
    insert into public.teacher_schedules (
      teacher_id,
      course_name,
      course_code,
      class_ids,
      class_names,
      location,
      weekday,
      period_start,
      period_end,
      start_time,
      end_time,
      start_week,
      end_week,
      week_type,
      semester,
      color
    )
    values (
      v_teacher_id,
      v_course_name,
      nullif(v_course_code, ''),
      array[v_managed_class_id],
      v_managed_class_name,
      v_course_location,
      1,
      1,
      2,
      '08:00',
      '09:40',
      1,
      18,
      'all',
      v_semester,
      '#4A7CFF'
    );
  end if;

  -- 绑定完成后，再按新关系回填旧业务数据
  update public.leave_applications la
  set class_id = s.class_id
  from public.students s
  where la.student_id = s.id;

  update public.leave_applications la
  set class_name = c.class_name
  from public.classes c
  where la.class_id = c.id;

  update public.grades g
  set class_id = s.class_id
  from public.students s
  where g.user_id = s.id;

  update public.grades g
  set teacher_schedule_id = ts.id
  from public.teacher_schedules ts
  where g.teacher_schedule_id is null
    and g.teacher_id = ts.teacher_id
    and g.semester = ts.semester
    and g.course_name = ts.course_name
    and g.class_id is not null
    and g.class_id = any(ts.class_ids);
end $$;

commit;

-- ============================================================================
-- 4. 执行后验证
-- 下面这些查询建议执行确认
-- ============================================================================

select
  u.name as user_name,
  u.email,
  u.student_id,
  s.student_no,
  c.class_name,
  c.head_teacher_id
from public.students s
join public.users u on u.id = s.id
join public.classes c on c.id = s.class_id
order by c.class_name, s.student_no;

select
  u.name as teacher_name,
  ts.semester,
  ts.course_name,
  ts.course_code,
  ts.class_names,
  ts.location
from public.teacher_schedules ts
join public.users u on u.id = ts.teacher_id
order by ts.semester desc, ts.course_name;

select
  la.id,
  la.student_name,
  la.class_name,
  la.status,
  la.teacher_id,
  la.class_id
from public.leave_applications la
order by la.created_at desc;

select
  g.id,
  g.course_name,
  g.semester,
  g.user_id,
  g.teacher_id,
  g.class_id,
  g.teacher_schedule_id
from public.grades g
order by g.created_at desc;
