- # 全局规范

  ## 语言要求

  - 所有回复、解释、分析必须使用简体中文
  - 代码注释使用中文
  - 报错信息先翻译成中文再分析原因
  - 代码变量名、函数名保持英文

  ## 代码规范

  - 使用 Flutter/Dart 风格命名
  - 优先使用项目已有的组件和工具类

  ## UI 开发规范

  遵循 ui-ux-pro-max skill 的设计原则， 但所有代码必须是 Flutter/Dart 实现。

  - CSS 样式转换为 Flutter 的 BoxDecoration、TextStyle、EdgeInsets
  - 布局使用 Column、Row、Stack、Padding、SizedBox
  - 动画使用 AnimatedContainer 或 flutter_animate 库
  - 颜色统一定义在 AppTheme 文件里，不允许硬编码
  - 所有间距使用 8 的倍数（8、16、24、32）

  # Flutter 开发规范

  ## 组件规范

  - 优先使用 StatelessWidget，需要状态时才用 StatefulWidget
  - 复杂状态使用 Provider 或 Riverpod 管理，不要在 Widget 里堆逻辑
  - 每个 Widget 文件只放一个主组件

  ## 命名规范

  - 文件名：snake_case（login_page.dart）
  - 类名：PascalCase（LoginPage）
  - 变量名：camelCase（userId）

  ## 禁止行为

  - 禁止在 build() 方法里做异步操作
  - 禁止硬编码颜色和字体大小，统一放到 theme 里

  # Supabase 规范

  ## 查询规范

  - 所有数据库操作必须处理 error，不能忽略
  - 查询结果判断先检查 error 再使用 data
  - 涉及用户数据的查询必须确认 RLS 策略

  ## 示例

  // 正确 final response = await supabase.from('users').select(); if (response.error != null) { // 处理错误 return; }

  ## 禁止行为

  - 禁止在客户端使用 service_role key
  - 禁止直接操作 auth.users 表

  # 数据库表结构规范

  ## 字段使用规范

  - 同目录下的 `table.csv` 是项目的数据库表结构定义，记录了所有已建表及其字段
  - 编写任何涉及数据库的代码前，必须先读取 `table.csv`，严格按照其中定义的表名和字段名编写，禁止自行假设或修改字段名
  - 如果代码中用到的字段在 `table.csv` 中不存在，禁止直接使用，必须按以下流程处理

  ## 缺失字段/表的处理流程

  1. 明确说明当前需要但 `table.csv` 中缺失的表名或字段名
  2. 生成对应的 SQL 建表/加字段语句，交给用户手动在 Supabase SQL Editor 中执行
  3. 等用户确认建表完成后，再继续生成业务代码，不得跳过此步骤

  ## SQL 生成规范

  - 生成的 SQL 必须包含字段类型、NOT NULL 约束、默认值、主键、外键等完整定义
  - 涉及用户关联的表必须附带 RLS 策略 SQL
  - SQL 语句统一用代码块包裹，并注明"请在 Supabase SQL Editor 中执行"

  ## 示例

  ```sql
  -- 示例：发现需要 user_profiles 表但 table.csv 中不存在时生成以下 SQL
  -- 请在 Supabase SQL Editor 中执行
  CREATE TABLE user_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname text NOT NULL,
    created_at timestamptz DEFAULT now()
  );
  ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "用户只能读写自己的数据" ON user_profiles
    USING (auth.uid() = user_id);
  ```

  # 报错处理规范

  收到报错时按以下步骤处理：

  1. 翻译报错信息为中文
  2. 说明报错原因（一句话）
  3. 给出解决方案（按优先级排列）
  4. 提供修复后的完整代码

  不要只给代码片段，要给可以直接替换的完整代码块。

  # 代码生成规范

  - 生成代码前先说明思路
  - 修改文件时只改动必要部分，不重写整个文件
  - 每次修改后说明改了哪里、为什么这样改
  - 如果有多种方案，列出优缺点让我选择