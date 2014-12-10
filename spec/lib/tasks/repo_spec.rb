require "spec_helper"
require "rake"

describe "namespace repo" do
  before :all do
    Rake.application.rake_require "tasks/repo"
    Rake::Task.define_task(:environment)
  end

  describe "task cleanup_orphans" do
    before do
      @repo1 = create :repo
      create :membership, repo: @repo1

      @repo2 = build(:repo).save
      @repo3 = build(:repo).save

      task = Rake::Task["repo:cleanup_orphans"]
      task.reenable
      task.invoke
    end

    it "removes repos without memberships" do
      expect(Repo.all).to eq([@repo1])
    end

  end
end
