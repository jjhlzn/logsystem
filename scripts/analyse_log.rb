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
    if /^订单\((V[0-9]{10})\)保存成功!$/ =~ log['content']
      puts "create_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'create_order', sellid:$1}
    end
  end
end

class CancelOrderAnalyzer < LogAnalyzer
  def check(request, log)
    #puts request
    #puts log
    if /^取消订单: (V[0-9]{10})$/ =~ log['content']
      puts "cancel_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'cancel_order', sellid:$1}
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


class PayOrderAnalyzer < LogAnalyzer
  def check(request, log)
    if /^start handle sellid\[(V[0-9]{10})\]$/ =~ log['content']
      puts "pay_order #{request['id']} #{log['id']} #{$1}"
      return {type: 'pay_order', sellid:$1}
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
    sql = "SELECT * FROM logsystem_requests_ordersystem order by id desc LIMIT 100000"
    #sql = "SELECT * FROM logsystem_requests_ordersystem WHERE id = 5296957 order by id desc LIMIT 100000"
    puts sql
    @client.query(sql).each do |request|
      sql = "SELECT * FROM logsystem_ordersystem WHERE id >= #{request['firstLog']} AND id <= #{request['endLog']} AND requestId = #{request['id']} "
      #puts sql
      logs = @client.query(sql)
      @analyzers.each do |analyzer|
        result = analyzer.analyse(request, logs)
        #print result
      end
    end
  end

  private

  def connect_db
    @client = Mysql2::Client.new(:host => 'www.hengdianworld.com', :username => 'hengdian', :password => '86547211', :database => 'lottery')
  end
end

mainAnalyzer = MainAnalyzer.new
#mainAnalyzer.analyzers.push(CreateOrderAnalyzer.new)
#mainAnalyzer.analyzers.push(CancelOrderAnalyzer.new)
mainAnalyzer.analyzers.push(PayOrderAnalyzer.new)
mainAnalyzer.analyse