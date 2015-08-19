require 'mysql2'


#寻找关于创建订单、付款、取消订单、审核订单的日志
class LogAnalyzer
  attr :client

  def initialize
    @client = connect_db
  end

  def analyse(request, logs)
    logs.each do |log|
      result = check(request, log)
      return result if result
    end
    nil
  end

  def check(request, log)
    false
  end

  private
  def connect_db
    @client = Mysql2::Client.new(:host => 'www.hengdianworld.com', :username => 'hengdian', :password => '86547211', :database => 'lottery')
  end

end


#查看日志里是否有'订单保存成功'
class CreateOrderAnalyzer < LogAnalyzer
  def check(request, log)
    if /^订单\(([V|F][0-9]{10})\)保存成功!$/ =~ log['content']
      puts "create_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'create_order', name: '创建订单', sellid: $1}
    end
  end

  def analyse(request, logs)
    results = []
    logs.each do |log|
      result = check(request, log)
      results.push(result) if result
    end
    if results.size == 0
      return nil
    else
      return results
    end
  end
end

#取消订单
class CancelOrderAnalyzer < LogAnalyzer
  def check(request, log)
    #puts request
    #puts log
    if /^取消订单: ([V|F][0-9]{10})$/ =~ log['content']
      puts "cancel_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'cancel_order', name: '取消订单', sellid: $1}
    end
  end

  def analyse(request, logs)
    results = []
    logs.each do |log|
      result = check(request, log)
      results.push(result) if result
    end
    if results.size == 0
      return nil
    else
      return results
    end
  end
end

#审核订单
class AuditOrderAnalyzer < LogAnalyzer
  def check(request, log)
    if /^审核订单: ([V|F][0-9]{10})$/ =~ log['content']
      puts "audit_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'audit_order', name: '订单审核', sellid: $1}
    end
  end

end

#支付推送
class PayOrderAnalyzer < LogAnalyzer
  def check(request, log)
    if /^start handle sellid\[([V|F][0-9]{10})\]$/ =~ log['content']
      puts "pay_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'pay_order', name: '订单付款', sellid: $1}
    end
  end
end

class MainAnalyzer
  attr :client
  attr :analyzers

  def initialize
    @client = connect_db
    @analyzers = []
  end

  def analyse
    last_request_id = get_last_parse_request_id()
    sql = "SELECT * FROM logsystem_requests_ordersystem WHERE id > #{last_request_id}"
    puts sql
    @client.query(sql).each do |request|
      sql = "SELECT * FROM logsystem_ordersystem WHERE id >= #{request['firstLog']} AND id <= #{request['endLog']} AND requestId = #{request['id']} "
      #puts sql
      logs = @client.query(sql)
      @analyzers.each do |analyzer|
        result = analyzer.analyse(request, logs)
        if result
          if result.class == Array
            result.each { |row| insert_order_log(request, row) }
          else
            insert_order_log(request, result)
          end
        end
      end
      update_last_parse_request_id(request['id'])
    end
  end

  private
  def connect_db
    @client = Mysql2::Client.new(:host => 'www.hengdianworld.com', :username => 'hengdian', :password => '86547211', :database => 'lottery')
  end

  def get_last_parse_request_id
    sql = "SELECT * FROM logsystem_orderparseposition WHERE application = 'ordersystem'"
    @client.query(sql).each do |row|
      return row['requestid']
    end
    return 0
  end

  def update_last_parse_request_id(request_id)
    sql = "UPDATE logsystem_orderparseposition SET requestid = #{request_id} WHERE application = 'ordersystem'"
    #puts sql
    @client.query(sql)
  end

  def insert_order_log(request, order_info)

    sql = <<-SQL
      INSERT INTO logsystem_orderlog_ordersystem (request_id, time, request_type, name, sellid)
      VALUES (#{request['id']}, '#{request['time']}', '#{order_info[:type]}', '#{order_info[:name]}', '#{order_info[:sellid]}')
    SQL
    #puts sql
    @client.query(sql)

  end
end

mainAnalyzer = MainAnalyzer.new
mainAnalyzer.analyzers.push(CreateOrderAnalyzer.new)
mainAnalyzer.analyzers.push(CancelOrderAnalyzer.new)
mainAnalyzer.analyzers.push(PayOrderAnalyzer.new)

while (1)
  mainAnalyzer.analyse
  sleep(2)
end