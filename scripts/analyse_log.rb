require 'mysql2'


#寻找关于创建订单、付款、取消订单、审核订单的日志
class LogAnalyzer
  attr :client

  def initialize
    @client = connect_db
  end

  def analyse
    sql = ''
  end

  private

  def connect_db
    @client = Mysql2::Client.new(:host => 'www.hengdianworld.com', :username => 'hengdian', :password => '86547211', :database => 'lottery')
  end

end


#查看日志里是否有'订单保存成功'
class CreateOrderAnalyzer < LogAnalyzer
  def analyse(request)
    start_log_id = request['firstLog']
    end_log_id = request['endLog']
    sql = "SELECT * FROM logsystem_ordersystem WHERE id >= #{start_log_id} AND id <= #{end_log_id}"
    #puts sql
    @client.query(sql).each do |log|
      #puts log['content']
      if /^订单\((V[0-9]{10})\)保存成功!$/ =~ log['content']
        puts "match #{request['id']} #{log['id']} #{$1}"
        return {type: 'create_oder', sellid:$1}
      end
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
    sql = "SELECT * FROM logsystem_requests_ordersystem LIMIT 1000"
    puts sql
    @client.query(sql).each do |log|
      @analyzers.each do |analyzer|
        result = analyzer.analyse(log)
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
mainAnalyzer.analyzers.push(CreateOrderAnalyzer.new)
mainAnalyzer.analyse