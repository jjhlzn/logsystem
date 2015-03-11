#encoding: utf-8
require 'date'
class LogsController < ApplicationController
  def index
    @logs = search(params)
  end

  def search (params)
    date = params[:date]
    from_time = params[:from_time]
    end_time = params[:end_time]
    thread = params[:thread]
    content = params[:thread]
    page_no = params[:page_no]
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

    if not thread.blank?
      query = query.where("thread = ?", thread)
    end

    if not content.blank?
      query = query.where("content like ?", "%#{content}%")
    end

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    return query.paginate :page => page_no, :per_page => page_size
  end
end
