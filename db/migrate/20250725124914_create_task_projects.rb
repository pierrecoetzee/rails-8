class CreateTaskProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :task_projects do |t|
      t.references :task, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
