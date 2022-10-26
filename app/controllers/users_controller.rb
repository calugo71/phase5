class UsersController < ApplicationController

  # GET /users
  def index
    token = request.headers['token']
    user_id = decode(token)
    user = User.find_by!(id: user_id)
    not_followed = User.all
    render json: not_followed
  end

  # GET users other than self to be followed
  def discover_bin_users
    token = request.headers['token']
    user_id = decode(token)
    bin = User.where.not(id: user_id)
    render json: bin
  end

  # GET users followings
  def follow_list
    token = request.headers['token']
    user_id = decode(token)
    user = User.find_by!(id: user_id)
    list = user.followings
    render json: list
  end

  # GET users followings posts
  def followings_posts
    token = request.headers['token']
    user_id = decode(token)
    user = User.find_by!(id: user_id)
    list = user.following_posts_list
    render json: list
  end

  #DELETE destroy self
  def delete_account
    token = request.headers['token']
    user_id = decode(token)
    user = User.find_by!(id: user_id)
    user.destroy
  end

  # #patch post to User
  # def add_post_to_user
  #   token = request.headers['token']
  #   user_id = decode(token)
  #   user = User.find(user_id)
  #   post = Post.create!(post:params[:post])
  #   render json: post
  # end

  # GET /users/1
  def show
    user = User.find_by!(id: params[:id])
    render json: user, serializer: NonfollowSerializer
  end

  # GET user_not_being_followed
  # def not_followed_yet
  #   token = request.headers['token']
  #   user_id = decode(token)
  #   user = User.find_by!(id: user_id)
  #   not_followed = User.where.not(followers: user_id).(id: params[:id], username: params[:username])
  #   render json: not_followed
  # end

  # POST /users
  def create
    user = User.create!(username: params[:username], password: params[:password])
    token = encode(user.id)
    render json: {user: user, token: token}
  end

  # PATCH/PUT /users/1
  def update
    token = request.headers['token']
    user_id = decode(token)
    user = User.find_by!(id: user_id)
    if user
      user.update(user_params)
      render json: user, status: :accepted
    else
      render json: { error: "Update not accepted :(" }, status: :not_found
    end
  end

  # DELETE /users/1
  def destroy
    token = request.headers['token']
    user_id = decode(token)
    user = User.find_by!(id: user_id)
    user.destroy
  end

  # LOGIN
    def login
      user = User.find_by!(username: params[:username]).try(:authenticate, params[:password])
      if user
        token = encode(user.id)
        render json: {user: user, token: token}
      else
        render json: { error: 'Wrong Password'}
      end
      # render json: user
    end
    # get profile
    def profile
      token = request.headers['token']
      user_id = decode(token)
      user = User.find(user_id)
      render json: user, serializer: ProfileSerializer
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.permit(:username, :password_digest, :posts, :likes, :comments, :followers, :followings)
    end
    
end
