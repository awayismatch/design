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
# 黑名单的功能可以后期再加上，只要系统设计的时候考虑一下这种可能性就行
CREATE TABLE blacklists
(
  id int(11) NOT NULL AUTO_INCREMENT,
  userId int(11) NOT NULL,
  targetUserId int(11) NOT NULL,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '用户黑名单';


#聊天
#socket.io


CREATE TABLE chatRooms
(
  id int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室';

CREATE TABLE chatUsers
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL,
  userId int(11) NOT NULL,
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天室里的用户';

#在消息这里，而要考虑多态的问题，比如说图片消息，文本消息，语音消息等。
CREATE TABLE messages
(
  id int(11) NOT NULL AUTO_INCREMENT,
  chatRoomId int(11) NOT NULL,
  type enum('text') NOT NULL DEFAULT 'text' comment '消息类型',
  `text` text comment '消息文本',
  #未来支持图片及语音后，直接在这里加入voiceLength,url的字段，
  #消息的多态问题由应用程序来判断，并选择相应需要使用的数据。
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '聊天消息';



CREATE TABLE messageNotifications
(
  id int(11) NOT NULL AUTO_INCREMENT,
  messageId int(11) NOT NULL,
  userId int(11) NOT NULL,
  status enum ('pending','received') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '未接受消息的用户列表';


# 每个profile都会有一个matchingProfile,当用户处于匹配状态时，是pending,当用户已经匹配成功或取消匹配时，处于close状态。

CREATE TABLE matchingProfiles
(
  id int(11) NOT NULL AUTO_INCREMENT,
  profileId int(11) NOT NULL,
  expGender enum ('男','女') NOT NULL comment '期望性别',
  expMinAge tinyint(2)  comment '期望最小年龄',
  expMaxAge tinyint(2)  comment '期望最大年龄',
  status enum('pending','close')  comment '当前状态',
  PRIMARY KEY (id)
) engine=innodb DEFAULT CHARSET=utf8 comment '等待匹配的人及其条件';

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