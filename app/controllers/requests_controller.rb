class RequestsController < ApplicationController
  def index
    date = params[:date]
    from_time = params[:from_time]
    end_time = params[:end_time]
    thread = params[:thread]
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

    query = Request.where("time >= ? AND time <= ?", from_time, end_time)

    if not content.blank?
      query = query.where("memo like ?", "%#{content}%")
    end

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    @requests = query.paginate :page => page_no, :per_page => page_size
  end

  def show
    request_id = params[:id]
    page_no = params[:page]
    page_size = 40

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    request = Request.where("id = ?", request_id).first
    firstLog = Log.where("id = ?", request.firstLog).first;
    @logs = Log.where("id >= ? AND id <= ? AND thread = ?", request.firstLog, request.endLog, firstLog.thread).paginate :page => page_no, :per_page => page_size
  end
end
