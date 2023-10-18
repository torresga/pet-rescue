class Organizations::PetsController < Organizations::BaseController
  before_action :verified_staff
  before_action :set_pet, only: [:show, :edit, :update, :update_images, :set_reason_paused_to_none]
  after_action :set_reason_paused_to_none, only: [:update]
  layout "dashboard"

  def index
    @unadopted_pets = Pet.unadopted_pets(current_user.staff_account.organization_id)
    @adopted_pets = Pet.adopted_pets(current_user.staff_account.organization_id)
    @pet = selected_pet
  end

  def new
    @pet = Pet.new
  end

  def edit
    return if pet_in_same_organization?(@pet.organization_id)

    redirect_to pets_path, alert: "This pet is not in your organization."
  end

  def show
    @active_tab = ["overview", "tasks", "applications", "files"].include?(params[:active_tab]) ? params[:active_tab] : "overview"
    @pause_reason = @pet.pause_reason
    return if pet_in_same_organization?(@pet.organization_id)

    redirect_to pets_path, alert: "This pet is not in your organization."
  end

  def create
    @pet = Pet.new(pet_params)

    if @pet.save
      redirect_to pets_path, notice: "Pet saved successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if pet_in_same_organization?(@pet.organization_id) && @pet.update(pet_params)
      redirect_to @pet, notice: "Pet updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_images
    @pet.append_images = params[:append_images]

    if @pet.save
      @active_tab = "files"
      redirect_to :show, notice: "Pet image updated successfully."
    else
      @active_tab = "files"
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    if pet_in_same_organization?(@pet.organization_id) && @pet.destroy
      redirect_to pets_path, notice: "Pet deleted.", status: :see_other
    else
      redirect_to pets_path, alert: "Error."
    end
  end

  private

  def pet_params
    params.require(:pet).permit(:organization_id,
      :name,
      :birth_date,
      :sex,
      :breed,
      :description,
      :application_paused,
      :pause_reason,
      :weight_from,
      :weight_to,
      :weight_unit,
      append_images: [])
  end

  def set_pet
    @pet = Pet.find(params[:id])
  end

  def selected_pet
    return if !params[:pet_id] || params[:pet_id] == ""

    Pet.where(id: params[:pet_id])
  end

  # update Pet pause_reason to not paused if applications resumed
  def set_reason_paused_to_none
    return unless pet.application_paused == false

    pet.pause_reason = 0
    pet.save!
  end
end
