/*
  # Initial Schema for Content Management System

  1. New Tables
    - `profiles` - User profiles with role management
    - `categories` - Content categories
    - `tags` - Content tags
    - `articles` - Main content table
    - `article_tags` - Many-to-many relationship for article tags
    - `comments` - User comments on articles
    - `likes` - User likes on articles
    - `bookmarks` - User bookmarks
    - `quizzes` - Quiz content
    - `quiz_questions` - Quiz questions
    - `quiz_answers` - Quiz answer options
    - `quiz_attempts` - User quiz attempts
    - `user_quiz_scores` - Quiz scoring
    - `daily_gk` - Daily general knowledge content
    - `user_points` - Gamification points system
    - `achievements` - User achievements
    - `user_achievements` - User achievement tracking
    - `notifications` - System notifications
    - `workflow_history` - Content approval workflow tracking

  2. Security
    - Enable RLS on all tables
    - Add appropriate policies for each role
    - Secure API access patterns

  3. Features
    - Role-based access control
    - Content approval workflow
    - Gamification system
    - Advanced search and filtering
*/

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE user_role AS ENUM (
  'superadmin',
  'admin', 
  'author',
  'contributor',
  'editor',
  'legaleditor',
  'moderator',
  'user'
);

CREATE TYPE content_status AS ENUM (
  'draft',
  'pending_review',
  'under_review',
  'approved',
  'published',
  'rejected',
  'archived'
);

CREATE TYPE content_type AS ENUM (
  'article',
  'opinion',
  'interview',
  'poem',
  'blog',
  'news',
  'tutorial'
);

CREATE TYPE quiz_difficulty AS ENUM (
  'easy',
  'medium',
  'hard',
  'expert'
);

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  full_name text,
  username text UNIQUE,
  avatar_url text,
  bio text,
  role user_role DEFAULT 'user',
  is_verified boolean DEFAULT false,
  points integer DEFAULT 0,
  level integer DEFAULT 1,
  streak_days integer DEFAULT 0,
  last_activity timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  color text DEFAULT '#3B82F6',
  icon text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  usage_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Articles table
CREATE TABLE IF NOT EXISTS articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  excerpt text,
  content text NOT NULL,
  featured_image text,
  content_type content_type DEFAULT 'article',
  status content_status DEFAULT 'draft',
  author_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id),
  editor_id uuid REFERENCES profiles(id),
  reviewer_id uuid REFERENCES profiles(id),
  published_at timestamptz,
  scheduled_at timestamptz,
  reading_time integer DEFAULT 0,
  view_count integer DEFAULT 0,
  like_count integer DEFAULT 0,
  comment_count integer DEFAULT 0,
  bookmark_count integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  is_trending boolean DEFAULT false,
  seo_title text,
  seo_description text,
  seo_keywords text[],
  rejection_reason text,
  editor_notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Article tags junction table
CREATE TABLE IF NOT EXISTS article_tags (
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  tag_id uuid REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (article_id, tag_id)
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id uuid REFERENCES comments(id) ON DELETE CASCADE,
  like_count integer DEFAULT 0,
  is_approved boolean DEFAULT false,
  is_flagged boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Likes table
CREATE TABLE IF NOT EXISTS likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, article_id)
);

-- Bookmarks table
CREATE TABLE IF NOT EXISTS bookmarks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, article_id)
);

-- Quizzes table
CREATE TABLE IF NOT EXISTS quizzes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  difficulty quiz_difficulty DEFAULT 'medium',
  category_id uuid REFERENCES categories(id),
  author_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  time_limit integer DEFAULT 300, -- seconds
  total_questions integer DEFAULT 0,
  max_attempts integer DEFAULT 3,
  passing_score integer DEFAULT 70,
  points_reward integer DEFAULT 10,
  is_active boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Quiz questions table
CREATE TABLE IF NOT EXISTS quiz_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid REFERENCES quizzes(id) ON DELETE CASCADE,
  question text NOT NULL,
  explanation text,
  points integer DEFAULT 1,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Quiz answers table
CREATE TABLE IF NOT EXISTS quiz_answers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id uuid REFERENCES quiz_questions(id) ON DELETE CASCADE,
  answer_text text NOT NULL,
  is_correct boolean DEFAULT false,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Quiz attempts table
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  score integer DEFAULT 0,
  total_questions integer DEFAULT 0,
  correct_answers integer DEFAULT 0,
  time_taken integer DEFAULT 0, -- seconds
  completed_at timestamptz,
  answers jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- User quiz scores table
CREATE TABLE IF NOT EXISTS user_quiz_scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  quiz_id uuid REFERENCES quizzes(id) ON DELETE CASCADE,
  best_score integer DEFAULT 0,
  attempts_count integer DEFAULT 0,
  last_attempt_at timestamptz,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, quiz_id)
);

-- Daily GK table
CREATE TABLE IF NOT EXISTS daily_gk (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  date date UNIQUE NOT NULL,
  category_id uuid REFERENCES categories(id),
  author_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  difficulty quiz_difficulty DEFAULT 'medium',
  points_reward integer DEFAULT 5,
  view_count integer DEFAULT 0,
  like_count integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- User points table
CREATE TABLE IF NOT EXISTS user_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  points integer NOT NULL,
  reason text NOT NULL,
  reference_type text, -- 'article', 'quiz', 'comment', 'daily_gk'
  reference_id uuid,
  created_at timestamptz DEFAULT now()
);

-- Achievements table
CREATE TABLE IF NOT EXISTS achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text NOT NULL,
  icon text,
  badge_color text DEFAULT '#FFD700',
  points_required integer DEFAULT 0,
  condition_type text NOT NULL, -- 'points', 'articles', 'quizzes', 'streak'
  condition_value integer NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- User achievements table
CREATE TABLE IF NOT EXISTS user_achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id uuid REFERENCES achievements(id) ON DELETE CASCADE,
  earned_at timestamptz DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  type text DEFAULT 'info', -- 'info', 'success', 'warning', 'error'
  reference_type text,
  reference_id uuid,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Workflow history table
CREATE TABLE IF NOT EXISTS workflow_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  from_status content_status,
  to_status content_status NOT NULL,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_quiz_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_gk ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_history ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Categories policies
CREATE POLICY "Anyone can view active categories" ON categories FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage categories" ON categories FOR ALL USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin')
  )
);

-- Tags policies
CREATE POLICY "Anyone can view tags" ON tags FOR SELECT USING (true);
CREATE POLICY "Authors can create tags" ON tags FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'author', 'contributor', 'editor')
  )
);

-- Articles policies
CREATE POLICY "Anyone can view published articles" ON articles FOR SELECT USING (
  status = 'published' OR 
  author_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'editor', 'legaleditor', 'moderator')
  )
);

CREATE POLICY "Authors can create articles" ON articles FOR INSERT WITH CHECK (
  auth.uid() = author_id AND
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'author', 'contributor')
  )
);

CREATE POLICY "Authors can update own articles" ON articles FOR UPDATE USING (
  author_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'editor', 'legaleditor')
  )
);

-- Comments policies
CREATE POLICY "Anyone can view approved comments" ON comments FOR SELECT USING (is_approved = true);
CREATE POLICY "Users can create comments" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comments" ON comments FOR UPDATE USING (auth.uid() = user_id);

-- Likes policies
CREATE POLICY "Users can view likes" ON likes FOR SELECT USING (true);
CREATE POLICY "Users can manage own likes" ON likes FOR ALL USING (auth.uid() = user_id);

-- Bookmarks policies
CREATE POLICY "Users can manage own bookmarks" ON bookmarks FOR ALL USING (auth.uid() = user_id);

-- Quiz policies
CREATE POLICY "Anyone can view active quizzes" ON quizzes FOR SELECT USING (is_active = true);
CREATE POLICY "Authors can create quizzes" ON quizzes FOR INSERT WITH CHECK (
  auth.uid() = author_id AND
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'author', 'contributor', 'editor')
  )
);

-- Quiz questions policies
CREATE POLICY "Anyone can view quiz questions" ON quiz_questions FOR SELECT USING (true);
CREATE POLICY "Quiz authors can manage questions" ON quiz_questions FOR ALL USING (
  EXISTS (
    SELECT 1 FROM quizzes 
    WHERE id = quiz_id 
    AND author_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'editor')
  )
);

-- Quiz answers policies
CREATE POLICY "Anyone can view quiz answers" ON quiz_answers FOR SELECT USING (true);
CREATE POLICY "Quiz authors can manage answers" ON quiz_answers FOR ALL USING (
  EXISTS (
    SELECT 1 FROM quiz_questions q
    JOIN quizzes qz ON qz.id = q.quiz_id
    WHERE q.id = question_id 
    AND qz.author_id = auth.uid()
  ) OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'editor')
  )
);

-- Quiz attempts policies
CREATE POLICY "Users can view own quiz attempts" ON quiz_attempts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create quiz attempts" ON quiz_attempts FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User quiz scores policies
CREATE POLICY "Users can view own quiz scores" ON user_quiz_scores FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can manage quiz scores" ON user_quiz_scores FOR ALL USING (true);

-- Daily GK policies
CREATE POLICY "Anyone can view daily GK" ON daily_gk FOR SELECT USING (true);
CREATE POLICY "Authors can create daily GK" ON daily_gk FOR INSERT WITH CHECK (
  auth.uid() = author_id AND
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'author', 'contributor', 'editor')
  )
);

-- User points policies
CREATE POLICY "Users can view own points" ON user_points FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can manage points" ON user_points FOR ALL USING (true);

-- Achievements policies
CREATE POLICY "Anyone can view achievements" ON achievements FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage achievements" ON achievements FOR ALL USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin')
  )
);

-- User achievements policies
CREATE POLICY "Users can view own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can manage user achievements" ON user_achievements FOR ALL USING (true);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "System can create notifications" ON notifications FOR INSERT WITH CHECK (true);

-- Workflow history policies
CREATE POLICY "Authors and editors can view workflow history" ON workflow_history FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM articles a
    WHERE a.id = article_id 
    AND (a.author_id = auth.uid() OR auth.uid() = user_id)
  ) OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('superadmin', 'admin', 'editor', 'legaleditor', 'moderator')
  )
);

CREATE POLICY "System can create workflow history" ON workflow_history FOR INSERT WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_articles_status ON articles(status);
CREATE INDEX IF NOT EXISTS idx_articles_author ON articles(author_id);
CREATE INDEX IF NOT EXISTS idx_articles_category ON articles(category_id);
CREATE INDEX IF NOT EXISTS idx_articles_published_at ON articles(published_at);
CREATE INDEX IF NOT EXISTS idx_articles_slug ON articles(slug);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_comments_article ON comments(article_id);
CREATE INDEX IF NOT EXISTS idx_likes_article ON likes(article_id);
CREATE INDEX IF NOT EXISTS idx_likes_user ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_user_points_user ON user_points(user_id);

-- Create functions for automatic updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON articles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_quizzes_updated_at BEFORE UPDATE ON quizzes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_daily_gk_updated_at BEFORE UPDATE ON daily_gk FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();