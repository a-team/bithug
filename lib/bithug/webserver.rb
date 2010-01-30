require "bithug"
require "sinatra/big_band"
require "md5"

module Bithug
  class Webserver < Sinatra::BigBand

    enable :sessions

    use Rack::Auth::Basic do |username, password|
      Bithug::User.login(username) if Bithug::User.authenticate(username, password)
    end

    helpers do

      def user_named(name)
        Bithug::User.find(:name => name).first
      end

      def user
        @user ||= user_named(params[:username])
      end

      def current_user
        user_named request.env['REMOTE_USER']
      end

      def current_user?
        user == current_user
      end

      def toggle_follow
        "#{"un" if current_user.following? user}follow"
      end

      def gravatar_url(mail, size, default)
        "http://www.gravatar.com/avatar/#{MD5::md5(mail)}?s=#{size}&d=#{default}"
      end

      def gravatar(mail, size = 80, default = "wavatar")
        "<img src='#{gravatar_url(mail, size, default)}' alt='' width='#{size}' height='#{size}'>"
      end

      def repo_named(name)
        Bithug::Repository.find(:name => name).first
      end

      def repo
        return unless user
        repo = repo_named(user.name / params[:repository])
        repo if repo and repo.check_access_rights(current_user)
      rescue Bithug::ReadAccessDeniedError
        nil
      end

      def owned?
        repo.owner == current_user
      end

      def title
        Bithug.title
      end

    end

    def follow_unfollow
      pass unless user
      yield unless current_user?
      current_user.save
      redirect "/#{params[:username]}"
    end

    get("/") { haml :dashboard }

    get "/:username/?" do
      # user.commits.recent(20)
      # user.network.recent
      # user.forks.recent(5)
      # user.rights.recent

      pass unless user
      haml :user
    end

    get("/:username/follow") do
      follow_unfollow { current_user.follow(user) }
    end

    get("/:username/unfollow") do
      follow_unfollow { current_user.unfollow(user) }
    end

    get "/:username/new" do
      pass unless current_user?
      haml :new_repository
    end

    post "/:username/new" do
      pass unless current_user?
      reponame = params["repo_name"]
      vcs = params["vcs"] || "git"
      Repository.create(:name => reponame, :owner => user, :vcs => vcs, :remote => params["remote"])
      redirect "/#{user.name}/#{reponame}"
    end

    get "/:username/settings" do
      pass unless current_user?
      haml :settings
    end
    
    post '/:username/settings' do
      pass unless current_user?
      user.real_name = params["real_name"]
      user.email = params["email"]
      user.save
      redirect "/#{user.name}/settings"
    end
    
    get "/:username/delete_key/:id" do
      pass unless current_user?
      key = Bithug::Key[params[:id]]
      key.remove(user) if user.ssh_keys.include? key
      redirect "/#{user.name}/settings"
    end

    post "/:username/add_key" do
      pass unless current_user?
      Bithug::Key.add :user => user, :name => params["name"], :value => params["value"]
      redirect "/#{user.name}/settings"
    end

    get "/:username/:repository/?" do
      pass unless repo
      # repo.tree <- returns a nested hash of the (w)hole repository tree
      haml :repository, {}, :commit_spec => "master", :tree => repo.tree("master"), :is_subtree => false
    end

    post "/:username/:repository/grant" do
      # epxects :read_or_write and :other_username
      pass unless repo and %w(w r).include? params[:read_or_write] and current_user? and user_named params[:other_username]
      user.grant_access :user => params[:other_username], :repo => repo, :access => params[:read_or_write]
      redirect "/#{repo.name}/admin"
    end

    post "/:username/:repository/revoke" do
      # epxects :read_or_write and :other_username
      pass unless repo and %w(w r).include? params[:read_or_write] and current_user? and user_named params[:other_username]
      user.revoke_access :user => params[:other_username], :repo => repo, :access => params[:read_or_write]
      redirect "/#{repo.name}/admin"
    end

    get "/:username/:repository/fork" do
      pass unless repo
      repo.fork current_user
      redirect "/#{current_user.name}/#{params[:repository]}"
    end

    get "/:username/:repository/:commit_spec/?*" do
      pass unless repo
      tree = params["splat"].first.split("/").inject repo.tree(params[:commit_spec]) do |subtree, subpath|
        pass unless subpath.include? subpath
        subpath[subtree]
      end
      haml :repository, {}, :tree => tree, :is_subtree => params["splat"].empty?, :commit_spec => params[:commit_spec]
    end

    get "/:username/feed" do
      pass unless current_user?
      haml :feed, {:layout => false, :format => :xhtml}, :log_entries => user.following.all.collect {|u| u.recent_activity}
    end

  end
end
