require 'will_paginate/array'
require 'date'

class RequestsController < ApplicationController
  def index
    @requests = search(params)
  end

  def exceptions
    params[:isError] = '1'
    @requests = search(params)
  end

  def show
    request_id = params[:id]
    date = params[:date]
    page_no = params[:page]
    page_size = 200

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    request = Request.find_by_sql(["SELECT * FROM #{get_request_table_name(params[:application], DateTime.parse(date))} WHERE id = ?", request_id]).first
    firstLog = Request.find_by_sql(["SELECT * FROM #{get_log_table_name(params[:application], DateTime.parse(date))} WHERE id = ?", request.firstLog]).first
    #Log.where('id = ?', request.firstLog).first;
    #@logs = Log.where('id >= ? AND id <= ? AND thread = ?', request.firstLog, request.endLog, firstLog.thread).paginate :page => page_no, :per_page => page_size
    Rails.logger.debug { "firstLog = #{firstLog}"}
    sql = "SELECT * FROM #{get_log_table_name(params[:application], DateTime.parse(date))} WHERE id >=  #{request.firstLog}
                                    AND id <= #{request.endLog} AND thread = '#{firstLog.thread}'"
    Rails.logger.debug {sql}
    @logs = Request.paginate_by_sql(sql, :page => page_no, :per_page => page_size)
  end

  def search(params)
    date = params[:date]
    from_time = params[:from_time]
    end_time = params[:end_time]
    is_error = params[:isError] == '1'
    ip = params[:ip]
    content = params[:content]
    page_no = params[:page]
    search_type = params[:search_type]
    page_size = 40

    if date.blank?
      date = DateTime.now.strftime('%F')
    end

    sql = "SELECT * FROM #{get_request_table_name(params[:application], DateTime.parse(date))} a WHERE 1=1  "

    if not from_time.blank?
      from_time = "#{date} #{from_time}"
      sql += " AND time >= '#{from_time}'"
    else
      #from_time = "#{date} 00:00:00"
    end

    if not end_time.blank?
      end_time = "#{date} #{end_time}"
      sql += " AND time <= '#{end_time}' "
    else
      #end_time = "#{date} 23:59:59,999"
    end


    if search_type == 'create_order'
      sql += " AND (SELECT  b.id FROM #{get_log_table_name(params[:application], DateTime.parse(date))} b WHERE b.content = '订单(#{content})保存成功!')  between a.firstLog AND a.endLog
               AND (SELECT b.requestId FROM #{get_log_table_name(params[:application], DateTime.parse(date))}  b WHERE b.content = '订单(#{content})保存成功!') = id"
    else
      if not content.blank?
        sql += " AND memo like '%#{content}%'"
      end
    end

    if not ip.blank?
      sql += " AND ip = '#{ip}'"
    end

    if is_error
      sql += ' AND (isError = 1 or isFatal = 1) '
    end

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    Rails.logger.debug { sql }
    @requests = Request.paginate_by_sql(sql, :page => page_no, :per_page => page_size)
  end


end
