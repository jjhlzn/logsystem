#encoding: utf-8
class Log < ActiveRecord::Base
  self.table_name = "logsystem_testordersystem"

  attr_accessor :request
end
