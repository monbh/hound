require "spec_helper"
require "rake"

describe "namespace repo" do
  before :all do
    Rake.application.rake_require "tasks/repo"
    Rake::Task.define_task(:environment)
  end

  describe "task remove_without_memberships" do
    it "removes repos without memberships" do
      repo = create(:repo)
      create(:membership, repo: repo)
      create(:repo).tap do |repo|
        repo.memberships.destroy_all
      end

      task = Rake::Task["repo:remove_without_memberships"]
      task.reenable
      task.invoke

      expect(Repo.all).to eq([repo])
    end
  end

  describe "task remove_duplicate_github_ids" do
    def run
      task = Rake::Task["repo:remove_duplicate_github_ids"]
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
      build(:repo, github_id: r1.github_id).tap do |repo|
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
      build(:repo, github_id: r1.github_id).tap do |repo|
        repo.save(validate: false)
      end

      run

      expect(Repo.all).to eq([r2])
    end
  end
end
