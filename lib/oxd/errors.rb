module Oxd
  # Error raised by oxd-ruby whenever an oxd Server Error is reported
  class ServerError < StandardError
    def initialize(errorObj)
    	error_msg = "oxd Server Error: #{errorObj['error']}\n #{errorObj['error_description']}"
      super(error_msg)
    end
  end

  # Error raised when oxd-server returns "invalid_ticket" error for the `uma_rp_get_rpt` command.
  class InvalidTicketError < StandardError
    def initialize(errorObj)
    	error_msg = "Invalid Ticket Error: #{errorObj['error_description']}"
      super(error_msg)
    end
  end

  # Error raised when oxd-server returns a "need_info" error for the `uma_rp_get_rpt` command.
  class NeedInfoError < StandardError
    def initialize(errorObj)
    	error_msg = "#{errorObj}"
      super(error_msg)
    end
  end

  # Error raised when UMA RP does an `uma_rp_check_access` on unprotected resource and the oxd server returns 'invalid_request' response.
  class InvalidRequestError < StandardError
    def initialize(errorObj)
    	error_msg = "Invalid Request Error: #{errorObj['error_description']}"
      super(error_msg)
    end
  end
end