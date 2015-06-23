require 'open-uri'
class ProjectsController < ApplicationController

  # GET /projects
  # GET /projects.xml
  def index
    @projects = current_user.projects
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = current_user.projects.find(params[:id])
    @story = @project.stories.build

    respond_to do |format|
      format.html # show.html.erb
      format.js   { render :json => @project }
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = current_user.projects.find(params[:id])
    @project.users.build
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = current_user.projects.build(allowed_params)
    @project.users << current_user

    respond_to do |format|
      if @project.save
        format.html { redirect_to(@project, :notice => t('projects.project was successfully created')) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = current_user.projects.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(allowed_params)
        format.html { redirect_to(@project, :notice => t('projects.project was successfully updated')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = current_user.projects.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

  # CSV import form
  def import
    @project = current_user.projects.find(params[:id])
  end

  # CSV import
  def import_upload

    @project = current_user.projects.find(params[:id])

    # Do not send any email notifications during the import process
    @project.suppress_notifications = true

    if params[:project][:import].blank?

      flash[:alert] = "You must select a file for import"

    else

      begin
        @project.update_attributes(allowed_params)
        @stories = @project.stories.from_csv(open(@project.import.fullpath).read)
        @valid_stories    = @stories.select(&:valid?)
        @invalid_stories  = @stories.reject(&:valid?)

        flash[:notice] = I18n.t(
          'imported n stories', :count => @valid_stories.count
        )

        unless @invalid_stories.empty?
          flash[:alert] = I18n.t(
            'n stories failed to import', :count => @invalid_stories.count
          )
        end
      rescue CSV::MalformedCSVError => e
        flash[:alert] = "Unable to import CSV: #{e.message}"
      end

    end

    render 'import'

  end

  protected

  def allowed_params
    params.fetch(:project,{}).permit(:name, :point_scale, :default_velocity, :start_date, :iteration_start_day, :iteration_length, :import)
  end

end
