#encoding: utf-8
require 'date'
class LogsController < ApplicationController
  def index
    @logs = search(params)
  end

  def exceptions
    params[:is_exception] = true
    @logs = search(params)
    #@logs.each do |log|
    #   Request.where()
    #end
  end

  def search (params)
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

    if not end_time.blank?
      end_time = "#{date} #{end_time}"
    else
      end_time = "#{date} 23:59:59,999"
    end

    query = Log.where("time > ? AND time < ?", from_time, end_time)
    
    if not level.blank?
      query = query.where("level = ?", level)
    end

    if not thread.blank?
      query = query.where("thread = ?", thread)
    end

    if not content.blank?
      query = query.where("content like ? OR clazz = ?", "%#{content}%", content)
    end

    if is_exception
      query = query.where('level in (?, ?)', 'ERROR', 'FATAL')
    end

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end
    
    return query.paginate :page => page_no, :per_page => page_size
  end
end
