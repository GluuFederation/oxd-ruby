class UmaController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'json'

    def index        
    end

    def protect_resources
        condition1_for_path1 = {:httpMethods => ["GET"], :scopes => ["http://photoz.example.com/dev/actions/view"]}
        condition2_for_path1 = {:httpMethods => ["PUT", "POST"], :scopes => ["http://photoz.example.com/dev/actions/all","http://photoz.example.com/dev/actions/add"], :ticketScopes => ["http://photoz.example.com/dev/actions/add"]}

        condition1_for_path2 = {:httpMethods => ["GET"], :scopes => ["http://photoz.example.com/dev/actions/view"]}

        @uma_command.uma_add_resource("/photo", condition1_for_path1, condition2_for_path1) # Add Resouyrece#1
        @uma_command.uma_add_resource("/document", condition1_for_path2) # Add Resouyrece#2
        response = @uma_command.uma_rs_protect # Register above resources with UMA RS
        render :template => "uma/index", :locals => { :protect_resources_response => response } 
    end

    def get_rpt
        rpt = @uma_command.uma_rp_get_rpt(false) # Get RPT
        render :template => "uma/index", :locals => { :rpt => rpt } 
    end

    def check_access
        response = @uma_command.uma_rs_check_access('/photo', 'GET')  # Pass the resource path and http method to check access
        render :template => "uma/index", :locals => { :check_access_response => response } 
    end

    def authorize_rpt
        response = @uma_command.uma_rp_authorize_rpt # Authorize RPT
        render :template => "uma/index", :locals => { :authorize_rpt_response => response }
    end

	def get_gat 
        scopes = ["http://photoz.example.com/dev/actions/add","http://photoz.example.com/dev/actions/view","http://photoz.example.com/dev/actions/edit"]
		gat = @uma_command.uma_rp_get_gat(scopes) # Pass scopes array to get GAT
        render :template => "uma/index", :locals => { :gat => gat } 
	end
end