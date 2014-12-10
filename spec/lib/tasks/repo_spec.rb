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

  describe "task cleanup_duplicate_github_ids" do
    def run
      task = Rake::Task["repo:cleanup_duplicate_github_ids"]
      task.reenable
      task.invoke
    end

    it "does not effect unduplicated rows" do
      repo = create :repo

      run

      expect(Repo.all).to eq([repo])
    end

    it "removes duplicate rows" do
      r1 = create(:repo)
      r2 = build(:repo, github_id: r1.github_id).tap do |repo|
        repo.save(validate: false)
      end

      run

      expect(Repo.count).to eq(1)
    end

    it "prefers active repos to inactive repos" do
      r1 = create(:repo)
      r2 = build(:repo, active: true, github_id: r1.github_id).tap do |repo|
        repo.save(validate: false)
      end
      r3 = build(:repo, github_id: r1.github_id).tap do |repo|
        repo.save(validate: false)
      end

      run

      expect(Repo.all).to eq([r2])
    end
  end
end
