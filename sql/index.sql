## 注：所有的表，都要按需加入updateAt及createAt字段。

#用户账号
CREATE TABLE users
(
  id int(11) NOT NULL AUTO_INCREMENT,
  phone varchar(20) NOT NULL,
  password varchar(70) NOT NULL comment '密码hash',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment 'user table';

# 个人资料
CREATE TABLE profiles
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) UNIQUE NOT NULL,
  avatar varchar(500) NOT NULL comment '头像',
  gender enum ('男','女') NOT NULL comment '性别',
  name varchar(70) NOT NULL comment '昵称',
  region varchar(100) NOT NULL comment '地区',
  birthday date NOT NULL comment '生日',
  email varchar(255)  comment '邮箱',
  whatsUp varchar(60) comment '个性签名',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '个人资料';

# 反馈
CREATE TABLE feedBacks
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL
  content varchar(255) comment '反馈内容',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '问题反馈';

# 聊天室，三种类型，朋友发起聊天，公开聊天室，私密聊天室
# 多态表，有一些字段只对于某一个字段有意义。
CREATE TABLE chatRooms
(
  id int(11) NOT NULL AUTO_INCREMENT,
  createrUserId int(11) NOT NULL comment '创建者userId',
  topic varchar(60) comment '主题',
  genderPlan enum('all','plan') not null default 'all' comment '聊天室的性别规划',
  totalAmount tinyint(1) comment '支持的总人数',
  femaleAmount tinyint(1) comment '支持的女生数量',
  maleAmount tinyint(1) comment '支持的男生数量',
  roomType enum('public','private','friend') not null default 'public' comment '聊天室类型',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室';

# 聊天室里的人。由于性别是无法改变的，可以考虑加入性别的字段来加速查询（目前没有这样子做）。
CREATE TABLE crAttenders
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL comment '聊天室id',
  userId int(11) NOT NULL comment '参与者id',
  status enum('attend','quit') not null default 'attend' comment '参与者状态',
  doNotDisturb enum('open','close') not null default 'close' comment '消息免打扰',
  saveChatRoom enum('open','close') not null default 'close' comment '保存到通讯录',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室参与者';

# 在聊天室里可以不看某人的消息，这个有区别于黑名单的功能。注意即使加入了黑名单，在聊天室里
# 也可以看到彼此的消息。
CREATE TABLE crBlockedUsers
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL comment '聊天室id',
  userId int(11) NOT NULL comment '参与者id',
  blockedUserId int(11) NOT NULL comment '被屏蔽的userId',
  block enum('open','close') not null default 'open' comment '是否不看此人的消息',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室里，不看某人的消息';


# 黑名单,用户的发消息请求都会走这个黑名单检查。
CREATE TABLE blockedUsers
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL ,
  blockedUserId int(11) NOT NULL comment '被加入黑名单的userId',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '用户黑名单';

# 用户举报，考虑检测当用户在一段时间内被举报的次数比较多时，会冻结账号。
CREATE TABLE reports
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL comment '举报者的userId',
  reportedUserId int(11) NOT NULL comment '被举报的userId',
  content varchar(255) NOT NULl comment '举报的内容',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '用户举报';

# 联系人
CREATE TABLE contacts
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  contactUserId int(11) NOT NULL comment '联系人userId',
  remark varchar(10) comment '备注信息',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '联系人';

# 请求添加为联系人（添加好友请求），
CREATE TABLE contactRequests
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  contactUserId int(11) NOT NULL comment '联系人userId',
  request varchar(60) comment '验证信息',
  remark varchar(10) comment '备注信息',
  status enum('pending','received','reject','accept') comment '该请求的状态'
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '请求加好友';

## 关于消息机制的表。

#聊天室消息，这里需要有时间戳，对于新加入聊天室的用户，只发送加入时间以后的消息。
CREATE TABLE crMessages
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL comment '聊天室id',
  userId int(11) NOT NULL comment '发送者id',
  content varchar(500) NOT NULL comment '消息内容',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室消息内容';

CREATE TABLE crMessageReceiveCursors
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL comment '聊天室id',
  LastestMessageId int(11) NOT NULL comment '聊天室最新接受的消息id',
  userId int(11) NOT NULL comment '消息接收者userId',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室接受消息的记录';

# 找回密码

CREATE TABLE passwordResetCodes
(
  id int(11) NOT NULL AUTO_INCREMENT,
  code varchar(255) NOT NULL comment '重置码',
  userId int(11) NOT NULL comment '重置密码的userId',
  status enum('fresh','used') NOT NULL comment '状态信息',
  password varchar(70) NOT NULL comment '未更改前的密码hash,用于存储历史密码',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '密码重置功能';

## 聊天室推荐功能
# crDisplayList //这个作为系统推荐的表，聊天室推荐列表以此表为依据

CREATE TABLE crDisplayItems
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL comment '聊天室id',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室版块展示的列表';

## 聊天室推荐功能，用户浏览情况的记录
CREATE TABLE crBrowseHistorys
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL comment '用户id',
  fromChatRoomId int(11) NOT NULL comment '浏览过的开始id',
  toChatRoomId int(11) NOT NULL comment '浏览过的结束id',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室板块列表的浏览记录id值从开始到结束的间隔';
