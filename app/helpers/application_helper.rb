require 'date'

module ApplicationHelper
  def get_log_table_name (application, date)
    return _get_table_name('logsystem_ordersystem', application, date)
  end

  def get_request_table_name (application, date)
    return _get_table_name('logsystem_requests_ordersystem', application, date)
  end

  def _get_table_name (table_name, application, date)
    if date.strftime('%F') == DateTime.now.strftime('%F')
      return table_name
    else
      return "`#{table_name}_#{date.strftime('%F')}`"
      #return table_name
    end
  end
end
