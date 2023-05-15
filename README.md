# 曲谱交流平台

### 一、介绍

曲谱交流平台主要面向音乐爱好者和音乐从业人员。这些人可以分享自己制作的曲谱，寻找他人分享的曲谱，相互交流学习音乐技巧和乐曲演奏方法，也可以发布自己的音乐作品，获得反馈和建议，同时还可以寻找志同道合的伙伴一起进行创作。此外，曲谱交流平台还可以吸引音乐产业从业人员，如唱片公司、音乐学校、音乐制作人等，通过平台上的作品发掘有潜力的音乐人才，或者向平台上的音乐人提供音乐制作和发布的机会。曲谱交流平台提供了一个方便的在线资源库，用户可以通过该平台浏览、搜索、上传、下载、评论曲谱，并与其他音乐人分享他们的创作和演奏经验。

### 二、实现语言

前端：HTML、CSS、JavaScript

后端框架：Ruby on Rails

数据库：SQLite

### 三、实体

- Songs-曲谱(id, 名称, 演唱, 作词, 作曲, song_types_id, manipulators_id)
- Song_types-曲谱类型(id, 名称)
- Pictures-图片(图片, songs_id, manipulators_id)
- Manipulators-操作者(id, 名称, 密码, 类型, pictures_id)
- Comments-评论(id, 内容, songs_id, manipulators_id)
- Reports-举报(id, 内容, 状态, comments_id, manipulators_id)
- Notices-通知(id, 类型, wh状态, ma状态, whistleblowers_id（举报者）, manipulators_id（被举报者）)

### 四、解释

- 一个曲谱有一种曲谱类型，一种曲谱类型有多个曲谱。（曲谱-曲谱类型, n:1）
- 一个曲谱有多张图片，一张图片属于一个曲谱。（曲谱-图片, 1:n）
- 操作者分为管理员和用户。
- 一个用户可以新建多个曲谱。（操作者-曲谱, 1:n）
- 一个用户可以上传多张曲谱照片。（操作者-图片, 1:n）
- 一个用户可以在一个曲谱上发表多个评论(包含文字, 表情包)。（曲谱-评论, 1:n；操作者-评论, 1:n）
- 一个用户可以在一个曲谱上举报多个评论。（用户-举报, 1:n；举报-评论, n:1）
- 一个用户可以上传图片作为头像。（操作者-图片, 1:1）
- 一个评论被举报时会通知双方该评论已被举报。（举报-通知, 1:1；操作者-通知, 1:n）

### 五、操作

- ##### 游客

  - 根据曲谱类型查看曲谱
  - 查看所有曲谱
  - 查看曲谱照片
  - 查看评论
  - 下载曲谱照片

- ##### 用户

  - 游客可以进行的操作，用户也行
  - 创建曲谱(名称、作词、作曲必填)
  - 创建曲谱类型(名称必填)
  - 为曲谱添加曲谱照片
  - 为曲谱添加评论(内容必填)
  - 修改个人信息(名字, 密码, 头像)
  - 举报评论(内容必填)
  - 更改通知信息状态(已读/未读)
  
- ##### 管理员

  - 用户可以进行的操作，管理员也行
  - 审核被举报的评论(若通过则删除评论，可查看待审核或已驳回的评论)
  - 删除用户和管理员



### 注意

本项目正在完成中，目前只是一个半成品，预计6月中可以完成，本项目在另一个仓库下会持续更新，可移步到https://github.com/011015/software-engineering
