class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.distinct.pluck(:rating).sort
    @ratings = params.key?("ratings") ? params["ratings"] : ratings_true
    @sort_type = params.key?('sort_type') ? params['sort_type'] : @sort_type
    
    @movies = Movie.order(@sort_type).where(:rating => @ratings.map { |k, v| k if v == "1" }.to_a)
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

  helper_method :sort_this
  def sort_this(col)
    @sort_type == col ? 'hilite' : nil
  end

  def ratings_true
    d = { }
    @all_ratings.each do |r|
      d[r] = "1"
    end
    d
  end
end
