# frozen_string_literal: true

# The controller for project pages /dashboard/projects.
class ProjectsController < ApplicationController
  # GET /projects/:id
  def show
    project_id = show_project_params[:id]
    @project = Project.find(project_id)
    if @project.nil?
      redirect_to(projects_path, alert: I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
    else
      @scripts = Script.all(@project.directory)
    end
  end

  # GET /projects
  def index
    @projects = Project.all
    @templates = templates
  end

  # GET /projects/new
  def new
    @templates = new_project_params[:template] == 'true' ? templates : []

    @project = Project.new
  end

  # GET /projects/:id/edit
  def edit
    project_id = show_project_params[:id]
    @project = Project.find(project_id)

    return unless @project.nil?

    redirect_to(projects_path, alert: I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
  end

  # PATCH /projects/:id
  def update
    project_id = show_project_params[:id]
    @project = Project.find(project_id)

    if @project.nil?
      redirect_to(projects_path, alert: I18n.t('dashboard.jobs_project_not_found', project_id: project_id))
      return
    end

    if @project.update(project_params)
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_manifest_updated')
    else
      message = @project.errors[:save].empty? ? I18n.t('dashboard.jobs_project_validation_error') : I18n.t('dashboard.jobs_project_generic_error', error: @project.collect_errors)
      flash.now[:alert] = message
      render :edit
    end
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_created')
    else
      message = @project.errors[:save].empty? ? I18n.t('dashboard.jobs_project_validation_error') : I18n.t('dashboard.jobs_project_generic_error', error: @project.collect_errors)
      flash.now[:alert] = message
      @templates = templates if project_params.key?(:template)
      render :new
    end
  end



  # DELETE /projects/:id
  def destroy
    project_id = params[:id]
    @project = Project.find(project_id)

    if @project.nil?
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_not_found', project_id: project_id)
      return
    end

    if @project.destroy!
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_deleted')
    else
      redirect_to projects_path, notice: I18n.t('dashboard.jobs_project_generic_error', error: @project.collect_errors)
    end
  end

  private

  def templates
    templates = Project.templates.map do |project|
      label = project.title
      data = {
        'data-description' => project.description,
        'data-icon'        => project.icon
      }
      [label, project.directory, data]
    end

    if templates.size.positive?
      templates.prepend(['', '', { 'data-description': '', 'data-icon': '' }])
    else
      []
    end
  end

  def project_params
    params
      .require(:project)
      .permit(:name, :directory, :description, :icon, :id, :template)
  end

  def show_project_params
    params.permit(:id)
  end

  def new_project_params
    params.permit(:template, :icon, :name, :directory)
  end
end
