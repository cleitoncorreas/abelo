# Copyright (C) 2007, Keegan Quinn
# Copyright (C) 2007, Colivre <http://www.colivre.coop.br>
#
# See http://keegan.sniz.net/articles/2007/05/27/showin-love-for-rails_rcov
# for original source (a patch for rails_rcov).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

namespace :test do
  desc "Run all tests with Rcov to measure coverage"
  task :rcov do |t|
    puts "Generating full test coverage report..."
    test_tasks = Rake::Task.tasks.select{ |t| t.comment && [ 'test:units', 'test:functionals', 'test:integration' ].include?(t.name) }
    for test_task in test_tasks
      Rake::Task[test_task.name + ':rcov'].invoke
    end
  end
end
