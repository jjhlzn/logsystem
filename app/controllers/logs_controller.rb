#encoding: utf-8
require 'date'
class LogsController < ApplicationController
  def index
    @logs = search(params)
  end

  def exceptions
    params[:is_exception] = true
    @logs = search(params)
    @logs.each do |log|
        log.request = Request.where('firstLog <= ? AND endLog >= ?', log.id, log.id).first
    end
  end

  def search (params)
    #去掉params所有值的空格
    params.each do |key, value|
      params[key] = value.strip if value.is_a? String
    end
    date = params[:date]
    from_time = params[:from_time]
    end_time = params[:end_time]
    thread = params[:thread]
    level = params[:level]
    content = params[:content]
    page_no = params[:page]
    is_exception = params[:is_exception]
    page_size = 40

    if date.blank?
      date = DateTime.now.strftime('%F')
    end

    if not from_time.blank?
      from_time = "#{date} #{from_time}"
    else
      from_time = "#{date} 00:00:00"
    end

    Rails.logger.debug { "params = #{params}" }
    Rails.logger.debug { "date = '#{date}'" }
    Rails.logger.debug { "from_time = '#{from_time}'" }
    Rails.logger.debug { "end_time = '#{end_time}'" }

    if not end_time.blank?
      end_time = "#{date} #{end_time}"
    else
      end_time = "#{date} 23:59:59,999"
    end

    sql = <<-SQL
      SELECT * FROM #{get_request_table_name(params[:application], DateTime.parse(date))}
      WHERE time > '#{from_time}' AND time < '#{end_time}'
    SQL
    #query = Log.where("time > ? AND time < ?", from_time, end_time)
    
    if not level.blank?
      #query = query.where("level = ?", level)
      sql += " AND level = '#{level}'"
    end

    if not thread.blank?
      #query = query.where("thread = ?", thread)
      sql += " AND thread = '#{thread}'"
    end

    if not content.blank?
      #query = query.where("content like ? OR clazz = ?", "%#{content}%", content)
      sql += " AND content like '%#{content}%' OR clazz = 'content'"
    end

    if is_exception
      #query = query.where('level in (?, ?)', 'ERROR', 'FATAL')
      sql += " AND level in ('ERROR', 'FATAL')"
    end

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    Rails.logger.debug { sql }
    return Request.paginate_by_sql(sql, :page => page_no, :per_page => page_size)
  end
end
