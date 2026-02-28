# 全局规范

## 语言要求
- 所有回复、解释、分析必须使用简体中文
- 代码注释使用中文
- 报错信息先翻译成中文再分析原因
- 代码变量名、函数名保持英文

## 代码规范
- 使用 Flutter/Dart 风格命名
- 优先使用项目已有的组件和工具类



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
// 正确
final response = await supabase.from('users').select();
if (response.error != null) {
  // 处理错误
  return;
}

## 禁止行为
- 禁止在客户端使用 service_role key
- 禁止直接操作 auth.users 表



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