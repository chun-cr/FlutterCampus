-- 请在 Supabase SQL Editor 中执行
-- 目的：
-- 1. 审计 public.users、public.students、public.teacher_profiles 是否一致
-- 2. 识别“真实注册账号”和“手工插入的虚拟学生/教师档案”
-- 3. 为后续关系迁移提供依据
--
-- 说明：
-- - 本脚本默认只查询，不删除数据
-- - 如需归档旧数据，脚本最后提供了“可选归档模板”

-- ============================================================================
-- A. 查看当前真实账号
-- public.users 才是当前 App 登录后实际依赖的账号主表
-- ============================================================================

select
  id,
  name,
  email,
  phone,
  type,
  student_id,
  department,
  created_at
from public.users
order by created_at;

-- ============================================================================
-- B. 查看当前 students 表中的档案
-- ============================================================================

select
  s.id,
  s.student_no,
  s.name,
  s.class_id,
  s.phone,
  s.email,
  s.status,
  s.created_at
from public.students s
order by s.created_at, s.student_no;

-- ============================================================================
-- C. 找出“已注册学生账号，但还没有对应 students 档案”的记录
-- 这些通常就是你手机号注册成功，但没绑定学籍关系的真实学生
-- ============================================================================

select
  u.id,
  u.name,
  u.email,
  u.phone,
  u.student_id,
  u.department,
  u.created_at
from public.users u
left join public.students s on s.id = u.id
where lower(coalesce(u.type, '')) like '%student%'
  and s.id is null
order by u.created_at;

-- ============================================================================
-- D. 找出“students 里有档案，但 public.users 里找不到同 ID 学生账号”的记录
-- 这些大概率就是历史手工插入的虚拟学生数据，或类型不一致的数据
-- ============================================================================

select
  s.id,
  s.student_no,
  s.name,
  s.class_id,
  s.phone,
  s.email,
  s.status,
  u.id as matched_user_id,
  u.type as matched_user_type,
  u.name as matched_user_name,
  u.student_id as matched_public_student_id
from public.students s
left join public.users u on u.id = s.id
where u.id is null
   or lower(coalesce(u.type, '')) not like '%student%'
order by s.created_at, s.student_no;

-- ============================================================================
-- E. 找出“students.student_no”和“public.users.student_id”可能能对上的记录
-- 这一步用于人工判断：某个虚拟 students 行是否其实对应某个真实注册学生账号
-- ============================================================================

select
  s.id as student_row_id,
  s.student_no,
  s.name as student_row_name,
  u.id as public_user_id,
  u.name as public_user_name,
  u.email,
  u.phone,
  u.student_id as public_user_student_id,
  case
    when s.student_no = u.student_id then 'student_no 精确匹配'
    when s.name = u.name then '姓名匹配'
    else '需人工确认'
  end as match_hint
from public.students s
join public.users u
  on lower(coalesce(u.type, '')) like '%student%'
 and (
      s.student_no = u.student_id
   or s.name = u.name
 )
order by s.student_no, s.name;

-- ============================================================================
-- F. 查看当前教师账号是否已经有 teacher_profiles 档案
-- ============================================================================

select
  u.id,
  u.name,
  u.email,
  u.phone,
  u.department,
  tp.teacher_no,
  tp.title,
  tp.office
from public.users u
left join public.teacher_profiles tp on tp.id = u.id
where lower(coalesce(u.type, '')) like '%teacher%'
order by u.created_at;

-- ============================================================================
-- G. 查看 students.class_id 是否能在 classes 表中找到
-- ============================================================================

select
  s.id,
  s.student_no,
  s.name,
  s.class_id,
  c.class_name,
  c.head_teacher_id
from public.students s
left join public.classes c on c.id = s.class_id
where c.id is null
order by s.created_at, s.student_no;

-- ============================================================================
-- H. 检查可能的重复学号
-- ============================================================================

select
  student_no,
  count(*) as duplicate_count
from public.students
group by student_no
having count(*) > 1
order by duplicate_count desc, student_no;

select
  student_id,
  count(*) as duplicate_count
from public.users
where student_id is not null
  and student_id <> ''
group by student_id
having count(*) > 1
order by duplicate_count desc, student_id;

-- ============================================================================
-- I. 可选归档模板
-- 只有在你确认某些 students 行是虚拟旧数据时，再手动取消注释执行
-- 不建议现在直接删
-- ============================================================================

-- create table if not exists public.students_legacy_backup as
-- select * from public.students where false;

-- insert into public.students_legacy_backup
-- select s.*
-- from public.students s
-- left join public.users u on u.id = s.id
-- where u.id is null
--    or lower(coalesce(u.type, '')) not like '%student%';

-- delete from public.students s
-- using public.students_legacy_backup b
-- where s.id = b.id;
