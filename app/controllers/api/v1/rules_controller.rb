class Api::V1::RulesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_rule, only: [:show, :update, :destroy]

  def index
    rules = Rule.order(:priority, :id)
    render json: rules
  end

  def show
    render json: @rule
  end

  def create
    rule = Rule.new(rule_params)

    if rule.save
      render json: rule, status: :created
    else
      render json: { errors: rule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @rule.update(rule_params)
      render json: @rule
    else
      render json: { errors: @rule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    head :no_content
  end

  private

  def set_rule
    @rule = Rule.find(params[:id])
  end

  def rule_params
    params.require(:rule).permit(:field, :operator, :value, :category, :priority)
  end
end
