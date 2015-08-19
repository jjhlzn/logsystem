#迁移日志进行分表
require 'mysql2'

class MigrateLog
  attr :client

  def initialize
    @client = connect_db
  end
  def main
    dates = [DateTime.now.strftime('%F')]
    dates.each do |date|
      fail("create table fail for #{date}!") unless create_table(date)
      fail("migrate logs fail for #{date}!") unless migrate_logs(date)
    end
  end

  def create_table(date)
    sql = """
        CREATE TABLE if not exists `logsystem_ordersystem_#{date}` (
          `id` int(11) NOT NULL,
          `time` varchar(200) NOT NULL,
          `thread` varchar(500) NOT NULL,
          `level` varchar(500) NOT NULL,
          `clazz` varchar(500) NOT NULL,
          `content` varchar(20000) NOT NULL,
          `requestId` int(11) DEFAULT NULL,
          PRIMARY KEY (`id`),
          KEY `index_time` (`time`)
        ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
    """
    print sql
    @client.query(sql)
    sql = """
      CREATE TABLE if not exists `logsystem_requests_ordersystem_#{date}` (
        `id` int(11) NOT NULL,
        `firstLog` int(11) DEFAULT NULL,
        `endLog` int(11) DEFAULT NULL,
        `memo` varchar(4000) DEFAULT NULL,
        `created_at` datetime DEFAULT NULL,
        `updated_at` datetime DEFAULT NULL,
        `time` varchar(255) DEFAULT NULL,
        `ip` varchar(100) DEFAULT NULL,
        `isFatal` bit(1) DEFAULT b'0',
        `isError` bit(1) DEFAULT b'0',
        `orderId` int(11) DEFAULT NULL,
        `requestType` varchar(255) DEFAULT NULL,
        PRIMARY KEY (`id`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    """
    @client.query(sql)
    return true
  end

  def migrate_logs(date)
    #migrate table logsystem_requests_ordersystem
    sql = "INSERT INTO `logsystem_requests_ordersystem_#{date}` SELECT * FROM logsystem_requests_ordersystem WHERE left(`time`, 10) = '#{date}';"
    print sql + "\n"
    @client.query(sql)
    sql = "DELETE FROM logsystem_requests_ordersystem WHERE left(`time`, 10) = '#{date}';"
    print sql + "\n"
    @client.query(sql)

    #migrate table logsystem_ordersystem
    sql = "INSERT INTO `logsystem_ordersystem_#{date}` SELECT * FROM logsystem_ordersystem WHERE left(`time`, 10) = '#{date}';"
    print sql + "\n"
    @client.query(sql)
    sql = "DELETE FROM logsystem_ordersystem WHERE left(`time`, 10) = '#{date}';"
    print sql + "\n"
    @client.query(sql)
    print "migrate log done.\n"
    return true
  end

  def connect_db
    @client = Mysql2::Client.new(:host => 'www.hengdianworld.com', :username => 'hengdian', :password => '86547211', :database => 'lottery')
  end

  def fail(msg)
    print msg
    exit(1)
  end

end

MigrateLog.new().main()