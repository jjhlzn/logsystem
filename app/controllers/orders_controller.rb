class OrdersController < ApplicationController
  def index
    @requests = search(params)
  end

  def show
    sellid = params[:sellid]
    sql = "SELECT * FROM logsystem_orderlog_ordersystem WHERE sellid = '#{sellid}'"
    Rails.logger.debug { sql }
    @orders = Order.find_by_sql(sql)
    respond_to do |format|
      format.json do
        render json: @orders
      end
    end
  end

  def search(params)
    date = params[:date]
    from_time = params[:from_time]
    end_time = params[:end_time]
    sellid = params[:sellid] ? params[:sellid].gsub(/\s+/, '') : ''
    page_no = params[:page]
    request_type = params[:request_type]
    page_size = 40

    if date.blank?
      date = DateTime.now.strftime('%F')
    end

    sql = "SELECT * FROM logsystem_orderlog_ordersystem WHERE 1=1  "

    if not from_time.blank?
      from_time = "#{date} #{from_time}"
      sql += " AND time >= '#{from_time}'"
    end

    if not end_time.blank?
      end_time = "#{date} #{end_time}"
      sql += " AND time <= '#{end_time}' "
    end

    if not sellid.blank?
      sql += " AND sellid = '#{sellid}' "
    end

    if page_no.blank?
      page_no = 1
    else
      page_no = page_no.to_i
    end

    Rails.logger.debug { sql }
    @orders = Order.paginate_by_sql(sql, :page => page_no, :per_page => page_size)
  end
end
