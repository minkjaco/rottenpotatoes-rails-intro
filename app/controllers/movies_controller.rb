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
    @all_ratings = all_ratings

    if (params["sort_type"].nil? || params["ratings"].nil?)
      @sort_type = params["sort_type"] || session[:sort_type] || ""
      @ratings = params["ratings"] || session[:ratings] || all_ratings_hash

      flash.keep
      redirect_to movies_path("sort_type" => @sort_type, "ratings" => @ratings)
      return
    end

    @sort_type = params["sort_type"]
    session[:sort_type] = @sort_type

    @ratings = params["ratings"]
    if @ratings.values.collect { |v| v == "0" }.all?
      @ratings = session[:ratings]
    end
    session[:ratings] = @ratings
  
    @movies = Movie.order(@sort_type)
    unless @ratings.nil?
      @movies = @movies.where(:rating => @ratings.map { |k, v| k if v == "1" }.to_a)
    end

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

  def all_ratings
    Movie.distinct.pluck(:rating).sort
  end

  def all_ratings_hash
    Hash[ @all_ratings.collect { |r| [r, "1"] } ]
  end

end
