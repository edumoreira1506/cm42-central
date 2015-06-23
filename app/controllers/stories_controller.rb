class StoriesController < ApplicationController

  include ActionView::Helpers::TextHelper

  def index
    @project = current_user.projects.with_stories_notes.find(params[:project_id])
    @stories = @project.stories
    respond_to do |format|
      format.json { render :json => @stories }
      format.csv do
        render :csv => @stories.order(:position), :filename => @project.csv_filename
      end
    end
  end

  def show
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    render :json => @story
  end

  def update
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    @story.acting_user = current_user
    respond_to do |format|
      if @story.update_attributes(allowed_params)
        format.html { redirect_to project_url(@project) }
        format.js   { render :json => @story }
      else
        format.html { render :action => 'edit' }
        format.js   { render :json => @story, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.find(params[:id])
    @story.destroy
    head :ok
  end

  def done
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.done
    render :json => @stories
  end
  def backlog
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.backlog
    render :json => @stories
  end
  def in_progress
    @project = current_user.projects.find(params[:project_id])
    @stories = @project.stories.in_progress
    render :json => @stories
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @story = @project.stories.build(allowed_params)
    @story.requested_by_id = current_user.id unless @story.requested_by_id
    respond_to do |format|
      if @story.save
        format.html { redirect_to project_url(@project) }
        format.js   { render :json => @story }
      else
        format.html { render :action => 'new' }
        format.js   { render :json => @story, :status => :unprocessable_entity }
      end
    end
  end

  def start
    state_change(:start!)
  end

  def finish
    state_change(:finish!)
  end

  def deliver
    state_change(:deliver!)
  end

  def accept
    state_change(:accept!)
  end

  def reject
    state_change(:reject!)
  end

  private
  def state_change(transition)
    @project = current_user.projects.find(params[:project_id])

    @story = @project.stories.find(params[:id])
    @story.send(transition)

    redirect_to project_url(@project)
  end

  def allowed_params
    params.require(:story).permit(:title, :description, :estimate, :story_type, :state, :requested_by_id, :owned_by_id, :position, :labels)
  end
end
