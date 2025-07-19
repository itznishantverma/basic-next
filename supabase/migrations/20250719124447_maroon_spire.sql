/*
  # Seed Initial Data

  1. Categories
  2. Tags  
  3. Achievements
  4. Sample content for testing
*/

-- Insert default categories
INSERT INTO categories (name, slug, description, color, icon) VALUES
('Technology', 'technology', 'Latest tech news and tutorials', '#3B82F6', 'Laptop'),
('Science', 'science', 'Scientific discoveries and research', '#10B981', 'Microscope'),
('Politics', 'politics', 'Political news and analysis', '#EF4444', 'Vote'),
('Sports', 'sports', 'Sports news and updates', '#F59E0B', 'Trophy'),
('Entertainment', 'entertainment', 'Movies, music, and celebrity news', '#8B5CF6', 'Film'),
('Health', 'health', 'Health and wellness articles', '#06B6D4', 'Heart'),
('Education', 'education', 'Educational content and resources', '#84CC16', 'GraduationCap'),
('Business', 'business', 'Business news and insights', '#F97316', 'Briefcase'),
('Travel', 'travel', 'Travel guides and experiences', '#EC4899', 'MapPin'),
('Food', 'food', 'Recipes and food culture', '#14B8A6', 'ChefHat'),
('General Knowledge', 'general-knowledge', 'Daily GK and facts', '#6366F1', 'Brain'),
('Current Affairs', 'current-affairs', 'Latest current affairs', '#DC2626', 'Newspaper')
ON CONFLICT (slug) DO NOTHING;

-- Insert default tags
INSERT INTO tags (name, slug, description) VALUES
('Breaking News', 'breaking-news', 'Latest breaking news'),
('Tutorial', 'tutorial', 'Step-by-step tutorials'),
('Review', 'review', 'Product and service reviews'),
('Interview', 'interview', 'Exclusive interviews'),
('Opinion', 'opinion', 'Opinion pieces and editorials'),
('Analysis', 'analysis', 'In-depth analysis'),
('Tips', 'tips', 'Helpful tips and tricks'),
('Guide', 'guide', 'Comprehensive guides'),
('Research', 'research', 'Research-based articles'),
('Trending', 'trending', 'Trending topics'),
('Featured', 'featured', 'Featured content'),
('Exclusive', 'exclusive', 'Exclusive content'),
('Quick Read', 'quick-read', 'Short articles for quick reading'),
('Deep Dive', 'deep-dive', 'Detailed long-form content'),
('Beginner', 'beginner', 'Content for beginners'),
('Advanced', 'advanced', 'Advanced level content'),
('Case Study', 'case-study', 'Real-world case studies'),
('How To', 'how-to', 'How-to articles'),
('List', 'list', 'List-based articles'),
('Infographic', 'infographic', 'Visual infographic content')
ON CONFLICT (slug) DO NOTHING;

-- Insert default achievements
INSERT INTO achievements (name, description, icon, badge_color, points_required, condition_type, condition_value) VALUES
('First Steps', 'Welcome! You''ve joined our community', 'Star', '#FFD700', 0, 'points', 0),
('Reader', 'Read your first article', 'BookOpen', '#3B82F6', 5, 'points', 5),
('Commenter', 'Leave your first comment', 'MessageCircle', '#10B981', 10, 'points', 10),
('Quiz Master', 'Complete your first quiz', 'Brain', '#8B5CF6', 15, 'points', 15),
('Daily Learner', 'Check daily GK for 7 consecutive days', 'Calendar', '#F59E0B', 50, 'streak', 7),
('Knowledge Seeker', 'Earn 100 points', 'Trophy', '#EF4444', 100, 'points', 100),
('Bookworm', 'Read 10 articles', 'Book', '#06B6D4', 150, 'articles', 10),
('Quiz Champion', 'Complete 5 quizzes', 'Award', '#84CC16', 200, 'quizzes', 5),
('Dedicated Reader', 'Maintain a 30-day reading streak', 'Flame', '#F97316', 300, 'streak', 30),
('Knowledge Expert', 'Earn 500 points', 'Crown', '#EC4899', 500, 'points', 500),
('Super Learner', 'Complete 20 quizzes', 'Zap', '#14B8A6', 750, 'quizzes', 20),
('Master Reader', 'Read 50 articles', 'GraduationCap', '#6366F1', 1000, 'articles', 50),
('Legend', 'Earn 1000 points', 'Diamond', '#DC2626', 1000, 'points', 1000)
ON CONFLICT (name) DO NOTHING;