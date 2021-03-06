class SavedSearchesController < ApplicationController
  before_filter :signed_in_user,
                only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]

  # GET /saved_searches
  # GET /saved_searches.json
  def index
    @saved_searches = current_user.saved_searchs

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @saved_searches }
    end
  end

  # GET /saved_searches/1
  # GET /saved_searches/1.json
  def show
    @saved_search = SavedSearch.find(params[:id])
    @saved_search.car_model.gsub!(' ','_')
    query_str = "year_to=#{@saved_search.year_to}&year_fr=#{@saved_search.year_fr}&modelstr=#{@saved_search.car_model}&price_fr=#{@saved_search.price_fr}&price_to=#{@saved_search.price_to}&keywords=#{@saved_search.keywords}"

    redirect_to "/ferraris?"+query_str
  end

  # POST /saved_searches
  # POST /saved_searches.json
  def create
    if(!current_user)
      render json: {status: "failed", message: "User needs to be logged in"}
      return
    end

    params[:saved_search][:user_id] = current_user.id

    if(params[:saved_search][:price_to] == "")
      params[:saved_search][:price_to] = -1.00
    end

    if(params[:saved_search][:price_fr] == "")
      params[:saved_search][:price_fr] = -1.00
    end

    saved_search = SavedSearch.new(params[:saved_search])

    respond_to do |format|
      if saved_search.save
        format.html { redirect_to saved_search, notice: 'Saved search was successfully created.' }
        format.json { render json: saved_search, status: :created, location: saved_search }
      else
        format.html { render action: "new" }
        format.json { render json: saved_search.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    @saved_search = SavedSearch.find(params[:id]);
    if(@saved_search.notify_me)
      @saved_search.notify_me = false;
    else
      @saved_search.notify_me = true;
    end
    @saved_search.save
    render json: @saved_search.notify_me
  end

  def update
    @savedSearch = SavedSearch.find(params[:id])
    params[:saved_search][:price_to] = params[:saved_search][:prce_to]
    params[:saved_search][:price_fr] = params[:saved_search][:prce_fr]
    if @savedSearch.update_attributes(params[:saved_search])
      flash[:success] = "Updated search"
      render json: @savedSearch
    else
      render 'edit'
    end
  end


  # DELETE /saved_searches/1
  # DELETE /saved_searches/1.json
  def destroy
    @saved_search = SavedSearch.find(params[:id])
    @saved_search.destroy

    respond_to do |format|
      format.html { redirect_to saved_searches_url }
      format.json { head :no_content }
    end
  end

  private
    def correct_user
      @saved_search = SavedSearch.find(params[:id])
      redirect_to(root_path) unless @saved_search.user_id == current_user.id
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
