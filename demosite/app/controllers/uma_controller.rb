class UmaController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'json'

    def index       
    end

    def get_client_token
        @oxd_command.get_client_token
        redirect_to uma_index_path
    end

    def protect_resources
        condition1_for_path1 = {:httpMethods => ["GET"], :scopes => ["https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1/view"]}
        condition2_for_path1 = {:httpMethods => ["PUT", "POST"], :scopes => ["https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1/all","https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1/add"], :ticketScopes => ["https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1/add"]}

        condition1_for_path2 = {:httpMethods => ["GET"], :scopes => ["https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1/all"]}

        @uma_command.uma_add_resource("/photo", condition1_for_path1, condition2_for_path1) # Add Resource#1
        @uma_command.uma_add_resource("/document", condition1_for_path2) # Add Resource#2

        response = @uma_command.uma_rs_protect # Register above resources with UMA RS
        render :template => "uma/index", :locals => { :protect_resources_response => response } 
    end

    def get_rpt
        response = @uma_command.uma_rp_get_rpt
        render :template => "uma/index", :locals => { :get_rpt_response => response } 
    end

    def check_access
        response = @uma_command.uma_rs_check_access('/photo', 'GET')  # Pass the resource path and http method to check access
        render :template => "uma/index", :locals => { :check_access_response => response } 
    end

    def get_claims_gathering_url
        response = @uma_command.uma_rp_get_claims_gathering_url('/photo')
        render :template => "uma/index", :locals => { :get_claims_gathering_url_response => response } 
    end
end