namespace :repo do
  desc 'Find 3,000 repos without privacy or organization information and update with info from GitHub'
  task backfill_privacy_and_organization: :environment do
    puts 'Finding repos ...'
    where_condition = <<-SQL
(private IS NULL OR in_organization IS NULL) AND updated_at IS NULL
    SQL
    repo_ids = Repo.where(where_condition).limit(3_000).pluck(:id)
    puts 'Scheduling RepoInformationJob jobs for repos ...'
    repo_ids.each do |repo_id|
      JobQueue.push(RepoInformationJob, repo_id)
    end
    puts 'Done scheduling jobs.'
  end

  desc "Delete repos with no memberships"
  task cleanup_orphans: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM repos
      WHERE id IN (
        SELECT repos.id FROM repos
        LEFT OUTER JOIN memberships on memberships.repo_id = repos.id
        WHERE memberships.id IS NULL
      )
    SQL
  end
end
