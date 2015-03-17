require 'will_paginate/array'

class RequestsController < ApplicationController
  def index
    @requests = search(params)
  end

  def exceptions
    params[:isError] = '1'
    @requests = search(params)
    @requests.each { |req| req.isNotError = (Log.where('id >= ? AND id <= ? AND level in (?, ?)', req.firstLog, req.endLog, 'FATAL', 'ERROR').count == 0) }
  end

  def show
    request_id = params[:id]
    page_no = params[:page]
    page_size = 200

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    request = Request.find_by_sql(["SELECT * FROM #{get_request_table_name(params[:application])} WHERE id = ?", request_id]).first
    firstLog = Log.where('id = ?', request.firstLog).first;
    @logs = Log.where('id >= ? AND id <= ? AND thread = ?', request.firstLog, request.endLog, firstLog.thread).paginate :page => page_no, :per_page => page_size
  end


  def search(params)
    date = params[:date]
    from_time = params[:from_time]
    end_time = params[:end_time]
    is_error = params[:isError] == '1'
    ip = params[:ip]
    content = params[:content]
    page_no = params[:page]
    page_size = 40

    if date.blank?
      date = DateTime.now.strftime('%F')
    end

    if not from_time.blank?
      from_time = "#{date} #{from_time}"
    else
      from_time = "#{date} 00:00:00"
    end

    if not end_time.blank?
      end_time = "#{date} #{end_time}"
    else
      end_time = "#{date} 23:59:59,999"
    end

    sql = "SELECT * FROM #{get_request_table_name(params[:application])} WHERE time >= '#{from_time}' AND time <= '#{end_time}'  "

    if not content.blank?
      sql += " AND memo like '%#{content}%'"
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
