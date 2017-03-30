# should set up ssl, and password will be transfer directly.

# 匹配时，不入库mysql，只在mongodb中记录当前正在匹配的用户
# 每有一个用户进入匹配时，会在mongodb中查询适合的用户，如果有，就匹配成功，如果没有，就存入mongodb中等待别人的匹配行为。
CREATE TABLE users
(
  id int(11) NOT NULL AUTO_INCREMENT,
  email varchar(255) NOT NULL,
  password varchar(70) NOT NULL comment '密码hash',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment 'user table';

CREATE TABLE profiles
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  avatar varchar(500) NOT NULL comment '头像',
  gender enum ('男','女') NOT NULL comment '性别',
  name varchar(70) NOT NULL comment '昵称',
  birthday date  comment '生日',
  position varchar(255)  comment '位置',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '个人资料';

# 匹配成功后，可以进行聊天，可以把聊天对象保存为联系人，若为联系人，关系永久保存，而只是聊天对象时，
# 软件重装等，都可能会造成记录删除。

CREATE TABLE contacts
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  contactUserId int(11) NOT NULL comment '联系人userId',
  remark varchar(30) comment '备注',
  note varchar(255) comment '用户注解',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '联系人关系';

# 为防止出现骚扰情况，添加‘黑名单’的功能，在聊天页面里面，可以设置加入黑名单。
CREATE TABLE blacklists
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  targetUserId int(11) NOT NULL,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '用户黑名单';


#聊天
#socket.io
#基本流程，匹配成功时，开一个transaction,插入一个match，并根据matchId，插入两条matchSubscribers(对应两个用户)

CREATE TABLE matchs
(
  id int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天匹配';

CREATE TABLE matchSubscribers
(
  id int(11) NOT NULL AUTO_INCREMENT,
  matchId int(11) NOT NULL,
  userId int(11) NOT NULL,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '匹配订阅者，通常为聊天者自己';

CREATE TABLE messages
(
  id int(11) NOT NULL AUTO_INCREMENT,
  matchId int(11) NOT NULL,
  type enum('text') NOT NULL DEFAULT 'text' comment '消息类型',
  `text` text comment '消息文本',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天消息';


# 匹配算法, 使用mtysql进行存储，直接通过查询语言进行筛选就行了。
## 匹配选项：1.年龄（范围） 2. 性别 3.位置（大致）
CREATE TABLE matchings
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  gender enum ('男','女') NOT NULL comment '期望性别',
  minAge varchar(4)  comment '期望最小年龄',
  maxAge varchar(4)  comment '期望最大年龄',
  -- position varchar(255)  comment '期望位置',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '等待匹配列表';
## 优先级：性别>年龄>位置

#当用户发送消息时，如果有subscriber不在线，subscriber的信息会被同步到msgReceivers里面，当用户接受消息时，会设置为received状态
CREATE TABLE msgReceivers
(
  id int(11) NOT NULL AUTO_INCREMENT,
  messageId int(11) NOT NULL,
  userId int(11) NOT NULL,
  status enum ('pending','received') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '未接受消息的用户列表';


#注册功能
#基本流程：
# 用户输入邮箱，确认后，系统发送注册邮件到邮箱上
# 用户进入邮箱，点击链接，打开一个html注册页面，页面提示输入密码，用户设置密码后，可以在app上登录。

#重置密码：
# 用户点击忘记密码，输入邮箱，确认后，系统发送密码重置邮件到邮箱上
# 用户进入邮箱，点击链接，打开一个html注册页面，页面提示输入密码，用户设置密码后，可以在app上用新密码登录。

CREATE TABLE registrationCode
(
  id int(11) NOT NULL AUTO_INCREMENT,
  code varchar(50) NOT NULL,
  email varchar(255) NOT NULL,
  activated tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '注册码';

CREATE TABLE pwdResetCode
(
  id int(11) NOT NULL AUTO_INCREMENT,
  code varchar(50) NOT NULL,
  email varchar(255) NOT NULL,
  activated tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '密码重置码';