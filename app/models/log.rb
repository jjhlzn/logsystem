#encoding: utf-8
class Log < ActiveRecord::Base
  self.table_name = "logsystem_ordersystem"

  attr_accessor :request
end
