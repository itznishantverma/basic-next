'use client'

import { useAuth } from '@/contexts/AuthContext'
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { BookOpen, Brain, Trophy, TrendingUp, Clock, Star, Users, Target } from 'lucide-react'
import { Card, CardContent, CardHeader } from '@/components/ui/Card'
import Header from '@/components/layout/Header'
import { formatRelativeTime } from '@/lib/utils'

export default function Dashboard() {
  const { user, profile } = useAuth()
  const [stats, setStats] = useState({
    articlesRead: 0,
    quizzesCompleted: 0,
    totalPoints: 0,
    currentStreak: 0,
    achievements: 0,
    readingTime: 0
  })
  const [recentActivity, setRecentActivity] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (user) {
      fetchDashboardData()
    }
  }, [user])

  const fetchDashboardData = async () => {
    try {
      // Fetch user stats
      const [
        { data: articles },
        { data: quizzes },
        { data: points },
        { data: achievements }
      ] = await Promise.all([
        supabase
          .from('bookmarks')
          .select('id')
          .eq('user_id', user.id),
        supabase
          .from('quiz_attempts')
          .select('id')
          .eq('user_id', user.id),
        supabase
          .from('user_points')
          .select('points')
          .eq('user_id', user.id),
        supabase
          .from('user_achievements')
          .select('id')
          .eq('user_id', user.id)
      ])

      const totalPoints = points?.reduce((sum, p) => sum + p.points, 0) || 0

      setStats({
        articlesRead: articles?.length || 0,
        quizzesCompleted: quizzes?.length || 0,
        totalPoints,
        currentStreak: profile?.streak_days || 0,
        achievements: achievements?.length || 0,
        readingTime: Math.floor(totalPoints / 10) // Estimate reading time
      })

      // Fetch recent activity
      const { data: activity } = await supabase
        .from('user_points')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(5)

      setRecentActivity(activity || [])
    } catch (error) {
      console.error('Error fetching dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  const statCards = [
    {
      title: 'Articles Read',
      value: stats.articlesRead,
      icon: BookOpen,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100'
    },
    {
      title: 'Quizzes Completed',
      value: stats.quizzesCompleted,
      icon: Brain,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100'
    },
    {
      title: 'Total Points',
      value: stats.totalPoints,
      icon: Star,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100'
    },
    {
      title: 'Current Streak',
      value: `${stats.currentStreak} days`,
      icon: TrendingUp,
      color: 'text-green-600',
      bgColor: 'bg-green-100'
    },
    {
      title: 'Achievements',
      value: stats.achievements,
      icon: Trophy,
      color: 'text-orange-600',
      bgColor: 'bg-orange-100'
    },
    {
      title: 'Reading Time',
      value: `${stats.readingTime} min`,
      icon: Clock,
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-100'
    }
  ]

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="h-32 bg-gray-200 rounded-lg"></div>
              ))}
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Section */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Welcome back, {profile?.full_name || 'User'}!
          </h1>
          <p className="text-gray-600">
            Here's your learning progress and recent activity.
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
          {statCards.map((stat, index) => {
            const Icon = stat.icon
            return (
              <Card key={index} className="hover:shadow-lg transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600 mb-1">
                        {stat.title}
                      </p>
                      <p className="text-2xl font-bold text-gray-900">
                        {stat.value}
                      </p>
                    </div>
                    <div className={`p-3 rounded-lg ${stat.bgColor}`}>
                      <Icon className={`w-6 h-6 ${stat.color}`} />
                    </div>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Recent Activity */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader>
                <h2 className="text-xl font-semibold text-gray-900">Recent Activity</h2>
              </CardHeader>
              <CardContent>
                {recentActivity.length > 0 ? (
                  <div className="space-y-4">
                    {recentActivity.map((activity, index) => (
                      <div key={index} className="flex items-center space-x-4 p-4 bg-gray-50 rounded-lg">
                        <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                          <Star className="w-5 h-5 text-blue-600" />
                        </div>
                        <div className="flex-1">
                          <p className="font-medium text-gray-900">
                            Earned {activity.points} points
                          </p>
                          <p className="text-sm text-gray-600">
                            {activity.reason}
                          </p>
                          <p className="text-xs text-gray-500">
                            {formatRelativeTime(activity.created_at)}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <Target className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-600">No recent activity</p>
                    <p className="text-sm text-gray-500">
                      Start reading articles or taking quizzes to see your activity here.
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Quick Actions */}
          <div>
            <Card>
              <CardHeader>
                <h2 className="text-xl font-semibold text-gray-900">Quick Actions</h2>
              </CardHeader>
              <CardContent className="space-y-4">
                <a
                  href="/articles"
                  className="flex items-center space-x-3 p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
                >
                  <BookOpen className="w-6 h-6 text-blue-600" />
                  <div>
                    <p className="font-medium text-gray-900">Browse Articles</p>
                    <p className="text-sm text-gray-600">Discover new content</p>
                  </div>
                </a>
                
                <a
                  href="/quizzes"
                  className="flex items-center space-x-3 p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors"
                >
                  <Brain className="w-6 h-6 text-purple-600" />
                  <div>
                    <p className="font-medium text-gray-900">Take Quiz</p>
                    <p className="text-sm text-gray-600">Test your knowledge</p>
                  </div>
                </a>
                
                <a
                  href="/daily-gk"
                  className="flex items-center space-x-3 p-4 bg-green-50 rounded-lg hover:bg-green-100 transition-colors"
                >
                  <TrendingUp className="w-6 h-6 text-green-600" />
                  <div>
                    <p className="font-medium text-gray-900">Daily GK</p>
                    <p className="text-sm text-gray-600">Learn something new</p>
                  </div>
                </a>
                
                <a
                  href="/dashboard/achievements"
                  className="flex items-center space-x-3 p-4 bg-yellow-50 rounded-lg hover:bg-yellow-100 transition-colors"
                >
                  <Trophy className="w-6 h-6 text-yellow-600" />
                  <div>
                    <p className="font-medium text-gray-900">Achievements</p>
                    <p className="text-sm text-gray-600">View your progress</p>
                  </div>
                </a>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}