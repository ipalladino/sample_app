class CarModelsController < ApplicationController
  before_filter :admin_user,     only: [:destroy, :create, :edit, :new]
  
  def index
    @paginate = false
    if(params[:from] && params[:to].blank?)
      year = Year.find_by_car_year(params[:from])
      @car_models = CarModel.where(year_id: year.id)
    elsif(params[:from] && params[:to])
      @car_models = CarModel.joins(:year).find(:all, :conditions => ['car_year >= ? AND car_year <= ?', params[:from], params[:to]])
    else
      @paginate = true
      @car_models = CarModel.joins(:year).order("car_year ASC").paginate(page: params[:page])
    end
    
    #@car_models = CarModel.paginate(page: params[:page])
  end
  
  def filter_by_year
    #debugger
    @car_models = CarModel.all
  end
  
  def filter_by_from_to
    @car_models = []
    if(params[:year_fr] == "Year Fr" || params[:year_fr].empty?)
      params[:year_fr] = nil
    end
    
    if(params[:year_to] == "Year To" || params[:year_to].empty?)
      params[:year_to] = nil
    end
    
    if(params[:year_fr]==nil && params[:year_to]==nil)
      render json: []
    end
    
    if(params[:year_fr] && params[:year_to])
      #if both year_fr and year_to are defined, we also need to check if they ar in right order
      yrfr = Integer(params[:year_fr])
      yrto = Integer(params[:year_to])
      if(yrfr <= yrto)
        #return correct stuff
        car_models = CarModel.joins(:year).find(:all, select: "car_model,car_models.id", :conditions => ['car_year >= ? AND car_year <= ?', params[:year_fr], params[:year_to]])
      end
    else
      #if only year_to is defined
      if(params[:year_to] && !params[:year_fr])
        car_models = CarModel.joins(:year).find(:all, select: "car_model,car_models.id",:conditions => ["car_year = ?", params[:year_to]])
      end
      #if only year_fr is defined
      if(params[:year_fr] && !params[:year_to])
        car_models = CarModel.joins(:year).find(:all, select: "car_model,car_models.id",:conditions => ["car_year = ?", params[:year_fr]])
      end
    end
    
    #MASSAGE FOR JS
    carmdx = []
    if(car_models)
      
      car_models.each do |c| 
        carmdx.push(c.serializable_hash)
      end
      mappings = {"id" => "value", "car_model" => "label"}
      carmdx.each do |y|
        y.keys.each { |k| y[ mappings[k] ] = y.delete(k) if mappings[k] }
      end

      render json: carmdx
    else
      render json: []
    end
    
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
