module Public
  class SubmissionsController < ApplicationController
    skip_before_action :update_last_seen
    layout "public"

    def new
      @form = Form.active.find_by!(slug: params[:form_slug])
      @form_fields = @form.form_fields
    end

    def create
      @form = Form.active.find_by!(slug: params[:form_slug])
      @form_fields = @form.form_fields

      custom_fields = {}
      @form_fields.each do |field|
        custom_fields[field.name] = params.dig(:lead, field.name)
      end

      @lead = Lead.new(
        name: params.dig(:lead, :name) || custom_fields["name"] || "이름없음",
        phone: params.dig(:lead, :phone) || custom_fields["phone"],
        email: params.dig(:lead, :email) || custom_fields["email"],
        form: @form,
        utm_source: params[:utm_source],
        utm_medium: params[:utm_medium],
        utm_campaign: params[:utm_campaign],
        utm_content: params[:utm_content],
        utm_term: params[:utm_term],
        referrer_url: request.referer,
        landing_page_url: request.original_url,
        ip_address: request.remote_ip,
        custom_fields: custom_fields
      )

      if @lead.save
        LeadAutoAssigner.call(@lead)
        broadcast_new_lead(@lead)
        redirect_to thank_you_path(form_slug: @form.slug)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def thank_you
      @form = Form.find_by!(slug: params[:form_slug])
    end

    private

    def broadcast_new_lead(lead)
      if lead.assigned_to_id
        ActionCable.server.broadcast(
          "lead_notifications_user_#{lead.assigned_to_id}",
          { type: "new_lead", lead_id: lead.id, name: lead.name, source: lead.utm_source }
        )
      end

      ActionCable.server.broadcast(
        "lead_notifications_global",
        { type: "new_lead", lead_id: lead.id, name: lead.name, source: lead.utm_source }
      )
    end
  end
end
