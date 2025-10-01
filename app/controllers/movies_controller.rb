class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
  
    if params[:ratings].present?
      @ratings_to_show   = params[:ratings].keys
      session[:ratings]  = params[:ratings]
    elsif session[:ratings].present?
      @ratings_to_show   = session[:ratings].keys
      @restore_ratings   = true
    else
      @ratings_to_show   = @all_ratings
    end
  
    allowed_sorts = %w[title release_date]
    if params[:sort_by].present? && allowed_sorts.include?(params[:sort_by])
      @sort_by          = params[:sort_by]
      session[:sort_by] = @sort_by
    elsif session[:sort_by].present? && allowed_sorts.include?(session[:sort_by])
      @sort_by        = session[:sort_by]
      @restore_sort   = true
    else
      @sort_by = nil
    end
  
    if @restore_ratings || @restore_sort
      ratings_hash = Hash[@ratings_to_show.map { |r| [r, "1"] }]
      return redirect_to movies_path(sort_by: @sort_by, ratings: ratings_hash)
    end
  
    scope   = Movie.with_ratings(@ratings_to_show)
    scope   = scope.reorder(nil)
    scope   = scope.order(@sort_by => :asc) if @sort_by
    @movies = scope
  end
  

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
