class CarModelsController < ApplicationController
  before_filter :admin_user,     only: [:destroy, :create, :edit, :new]
  
  def index
    @car_models = CarModel.joins(:year).order("car_year ASC").paginate(page: params[:page])
    #@car_models = CarModel.paginate(page: params[:page])
  end
  
  def show
    @car_model = CarModel.find(params[:id])
    #@trims = @carmodel.car_models.paginate(page: params[:page])
    #@engines = @carmodel.car_models.paginate(page: params[:page])
    #@transmissions = @carmodel.car_models.paginate(page: params[:page])
  end
  
  def create
    year = Year.find(params[:car_model][:year_id])
    params[:car_model].delete :year_id

    @carmodel = year.car_models.build(params[:car_model])
    if @carmodel.save
      flash[:success] = "Car model added!"
      redirect_to car_models_path
    else
      @feed_items = []
      render 'car_models/'
    end
  end
  
  def edit
    @years = Year.all
    @carmodel = CarModel.find(params[:id])
    5.times { @carmodel.generic_images.build }
  end

  def update
    @carmodel = CarModel.find(params[:id])
    if @carmodel.update_attributes(params[:car_model])
      flash[:success] = "The Ferrari post was updated"
      redirect_to @carmodel
    else
      @years = Year.all
      @carmodel = CarModel.find(params[:id])
      5.times { @carmodel.generic_images.build }
      render 'new'
    end
  end
  
  def destroy
    @carmodel = CarModel.find(params[:id])
    if @carmodel.destroy
        flash[:success] = "Car model removed successfully"
    end 
    redirect_to car_models_path
  end

  def new
    @carmodel = CarModel.new
    @years = Year.order("car_year ASC").all
    5.times { @carmodel.generic_images.build }
  end
  
  private 
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
