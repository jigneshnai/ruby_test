class ArticlesController < ApplicationController

	before_action :set_article, only: [:show, :edit, :update, :destroy]
	before_action :require_user, except: [:show, :index]
	before_action :require_same_user, only: [:show, :edit, :update, :destroy]

	def index
		#@articles = Article.all
		@articles = Article.paginate(page: params[:page], per_page: 6)
		#fresh_when(@articles)
	end	
	
	def show
		#\@article = Article.find(params[:id])
	end

	def new
		@article = Article.new
	end

	def create
		@article = Article.new(article_params_CU)
		@article.user = current_user
		if @article.save
			#redirect_to article_path(@article)
			flash[:notice] = "Article Added Succesfully"
			redirect_to @article	
		else
			render 'new'
		end
	end

	def edit
		#@article = Article.find(params[:id])
	end

	def update
		#@article = Article.find(params[:id])
		if @article.update(article_params_CU)
			flash[:notice] = "Article Updated Succesfully"
			redirect_to @article
		else
			render 'edit'
		end
	end

	def destroy
		#@article = Article.find(params[:id])
		@article.destroy
		flash[:notice] = "Article Deleted Succesfully"
		redirect_to articles_path
	end

	def set_article
		@article = Article.find(params[:id])		 
	end

	def article_params_CU
		params.require(:article).permit(:title,:description)
	end

	def require_same_user
		if current_user != @article.user && !current_user.admin?
			flash[:alert] = "You can only edit or delete your own articles"
			redirect_to articles_path
		end	
	end

####################### MY CODE ####################################

	def get_all_article
		
		#title_data = params[:data]

		#@article = Article.find_by_title(title_data)

		#@article = Article.where("title Like ?", "%#{sanitize_sql_like(title_data)}%").all

		#@article_data = Article.where(id:1)
		@article_data = Article.all
		#byebug
		#render :action => '/articles/test'
		# if stale?(@article_data)
			render "articles/mycode/view"
		# end	
	end

	def add_article_view

		@article = Article.new
		@categories = Category.all
		render "articles/mycode/add_view"
		
	end
	
	def article_add

		@categoryids = params[:categories]

		@categoryids = @categoryids.blank? ? [] : @categoryids.map { |cat| cat.to_i }

		@article = Article.new(
			title: 			params[:title], 
			description: 	params[:description], 
			user_id: 		current_user.id, 
			category_id: 	@categoryids)
		
		if @article.save
			#render :json => {:status => true, :redirect_to => get_articles_url}			
			respond_to do |f|	
				flash[:notice] = "Article Added Succesfully"		
			  	f.html { redirect_to get_articles_path}			
			end
		else
			
			render :json => {:status => false, :errors => @article.errors.full_messages}
		end

		# @article[:title] = params[:title]
		# @article[:description] = params[:description]

		# if @article.save			
		# 	redirect_to '/get_articles', flash: {notice: "Article Was Added Successfully"}
		# else
		# 	render "articles/mycode/add_view"
		# end

		#Article.create(:title => params[:title], :description => params[:description])

		#redirect_to '/get_articles'
		#redirect_to :back
		
	end

	def edit_article
		title_data = params[:data]

		@edt_article = Article.find_by_title(title_data)
		
		@article_data = Article.all
		
		@categories = Category.all

		render "articles/mycode/edit_view"
	end

	def article_updated

		@categoryids = params[:categories]

		@categoryids = @categoryids.blank? ? [] : @categoryids.map { |cat| cat.to_i }
		
		@articleid = params[:id]
		
		@article = Article.update(@articleid, 
			title: 			params[:title], 
			description: 	params[:description],
			category_id: 	@categoryids)
		
		
		# flash[:notice] = "Article Updated Succesfully"		
		# redirect_to '/get_articles'	

		if @article
			#render :json => {:status => true, :redirect_to => get_articles_url}			
			respond_to do |f|	
				flash[:notice] = "Article Updated Succesfully"		
			  	f.html { redirect_to '/get_articles'}			
			end
		else			
			render :json => {:status => false, :errors => @article.errors.full_messages}
		end
	end

	def delete_article
		@article_id = params[:data]

		Article.destroy(@article_id)

		redirect_to '/get_articles'
	end
end