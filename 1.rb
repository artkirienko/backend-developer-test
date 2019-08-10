class InfographicsController < ApplicationController
  # allows user to change their infographic title
  def update
    @infographic = Infographic.find(params[:id])
    if @infographic.update_attributes(update_params)
      render json: @infographic
      # Codestyle concern: we have 'status: 422' two lines below
      # why there is no 'status: 200' here
      # and status: :ok is friendlier for human then status: 200
      #
      # We don't send location header (we need, since we updated object)
      #
      # We render all the object attributes (even if js-frontend/microservice/client
      # don't need all of them and shouldn't really know about existence of some of them)
      # because we skip the view layer
      # (some erb/jbuilder/rabl templates / ActiveModel::Serializer / fast_jsonapi)
      #
      # my variant:
      # render :show, status: :ok, location: @infographic
    else
      render json: { errors: @infographic.errors.full_messages }, status: 422
      # The main concern here is about error messages
      # right now it is useless for js-frontend/microservice/client since
      # js-frontend/microservice/client don't know what field the message is
      # related to:
      # {
      #   "errors": [
      #     "Title is too short (minimum is 5 characters)"
      #   ]
      # }
      # should be:
      # {
      #   "title": [
      #     "is too short (minimum is 5 characters)"
      #   ]
      # }
      #
      # codestyle concern: 'unprocessable_entity' is friendlier for human
      # then '422'
      #
      # my variant:
      # render json: { errors: @infographic.errors }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.require(:infographic).permit(:title)
  end
end
