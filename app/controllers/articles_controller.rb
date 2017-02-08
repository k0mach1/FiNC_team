class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :confirm_permission, only: [:edit, :update, :destroy]

  def index
    groups = current_user.groups - [ Group.find(MASTER_GROUP_ID) ]
    group_ids = groups.map(&:id)
    viewable_articles = Article.group_articles(group_ids) | Article.public_articles
    @articles = if params[:tag]
                  viewable_articles.tagged_with(params[:tag]).where(group_id: nil)
                else
                  viewable_articles
                end
  end

  def show
    @comments = @article.comments
    @stock = Stock.new
    @article_like = ArticleLike.find_by(
      user_id: current_user.id,
      article_id: params[:article_id]
    )
  end

  def new
    @group = if params[:group_id]
               Group.find(params[:group_id])
             else
               Group.find(MASTER_GROUP_ID)
             end
    @article = Article.new
  end

  def edit; end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article, notice: '新しく投稿しました'
    else
      redirect_to root_path, alert: '新しい投稿ができませんでした'
    end
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: '投稿を編集しました'
    else
      redirect_to @article, alert: '投稿の編集ができませんでした'
    end
  end

  def destroy
    @article.destroy
    redirect_to ''
  end

  private

  def article_params
    params.require(:article).permit(
      :title,
      :body,
      :tag_list,
      :group_id
    ).merge(user_id: current_user.id)
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def confirm_permission
    redirect_to '', alert: '権限がありません' unless @article.user == current_user
  end
end
