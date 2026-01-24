<template>
  <div class="dashboard-container">
    <!-- 顶部欢迎卡片 -->
    <div class="welcome-card">
      <div class="welcome-content">
        <div class="user-info">
          <el-avatar :size="72" :src="require('@/assets/logo.png')" class="user-avatar" />
          <div class="user-details">
            <h2 class="welcome-title">早上好，{{ loginUser.nickname }}！</h2>
            <p class="welcome-subtitle">
              <i class="el-icon-sunny"></i>
              今天又是充满活力的一天，努力工作，成就自我！
            </p>
          </div>
        </div>
        <div class="stats-cards">
          <div class="stat-card" style="--card-color: #36c">
            <div class="stat-icon">
              <i class="el-icon-menu"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatNumber(statistics.validGameCount) }}</div>
              <div class="stat-label">有效游戏</div>
            </div>
            <div class="stat-total">
              总计 {{ formatNumber(statistics.totalGameCount) }}
            </div>
          </div>
          <div class="stat-card" style="--card-color: #f5a623">
            <div class="stat-icon">
              <i class="el-icon-finished"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatNumber(statistics.totalActiveCount) }}</div>
              <div class="stat-label">总激活数</div>
            </div>
            <div class="stat-total">
              总计 {{ formatNumber(statistics.totalCdkCount) }}
            </div>
          </div>
          <div class="stat-card" style="--card-color: #7ed321">
            <div class="stat-icon">
              <i class="el-icon-monitor"></i>
            </div>
            <div class="stat-content">
              <div class="stat-value">1,689</div>
              <div class="stat-label">客户端激活</div>
            </div>
            <div class="stat-total">
              今日 2,898
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 核心指标卡片 -->
    <div class="metrics-grid">
      <div class="metric-card" v-for="(item, index) in metrics" :key="index" :style="getMetricColor(index)">
        <div class="metric-header">
          <div class="metric-icon">
            <i :class="item.icon"></i>
          </div>
          <div class="metric-title">{{ item.label }}</div>
        </div>
        <div class="metric-value">{{ item.value }}</div>
        <div class="metric-progress">
          <el-progress
            :percentage="item.percent"
            :stroke-width="8"
            :show-text="false"
            :color="getProgressColor(item.percent)"
          />
          <span class="metric-percent">{{ item.percent }}%</span>
        </div>
        <div class="metric-trend">
          <i class="el-icon-top" v-if="item.trend > 0"></i>
          <i class="el-icon-bottom" v-else></i>
          <span :class="['trend-value', item.trend > 0 ? 'up' : 'down']">
            {{ Math.abs(item.trend) }}%
          </span>
          <span class="trend-label">较昨日</span>
        </div>
      </div>
    </div>

    <!-- 图表区域 -->
    <div class="chart-section">
      <div class="main-chart">
        <div class="chart-header">
          <h3>激活数据趋势</h3>
          <div class="chart-actions">
            <el-radio-group v-model="chartRange" size="small">
              <el-radio-button label="7d">近7天</el-radio-button>
              <el-radio-button label="30d">近30天</el-radio-button>
              <el-radio-button label="90d">近90天</el-radio-button>
            </el-radio-group>
            <el-button type="text" size="small" icon="el-icon-download">导出</el-button>
          </div>
        </div>
        <div ref="lineChart" class="chart-container"></div>
      </div>

      <div class="goal-card">
        <div class="goal-header">
          <h3>余额概览</h3>
          <el-tag type="success" size="small">本月达标</el-tag>
        </div>
        <div class="goal-content">
          <el-progress
            :width="160"
            :percentage="85"
            type="dashboard"
            :color="['#36c', '#6739b6', '#f2719c']"
          />
          <div class="goal-info">
            <div class="goal-current">
              <div class="goal-amount">¥ 2,850</div>
              <div class="goal-label">当前余额</div>
            </div>
            <div class="goal-target">
              <div class="goal-target-value">目标 ¥ 3,000</div>
              <div class="goal-progress">已完成 85%</div>
            </div>
          </div>
        </div>
        <div class="goal-stats">
          <div class="stat-item">
            <div class="stat-number">+12.5%</div>
            <div class="stat-text">较上月</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">28</div>
            <div class="stat-text">消费次数</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">5</div>
            <div class="stat-text">充值次数</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 代理列表 -->
    <div class="agent-section">
      <div class="section-header">
        <h3>代理管理</h3>
        <div class="header-actions">
          <el-input
            v-model="searchText"
            placeholder="搜索代理..."
            size="small"
            style="width: 200px;"
            prefix-icon="el-icon-search"
            clearable
          />
          <el-button type="primary" size="small" icon="el-icon-plus">新增代理</el-button>
        </div>
      </div>
      <div class="agent-table">
        <el-table
          :data="filteredAgents"
          style="width: 100%"
          :header-cell-style="{ background: '#fafafa', color: '#303133' }"
        >
          <el-table-column type="index" label="序号" width="60" align="center" />
          <el-table-column prop="projectName" label="代理名称" min-width="120">
            <template slot-scope="{ row }">
              <div class="agent-name">
                <el-avatar :size="32" :src="getAgentAvatar(row.projectName)" />
                <div class="agent-info">
                  <div class="agent-title">{{ row.projectName }}</div>
                  <div class="agent-id">ID: {{ row.id || 'N/A' }}</div>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="激活数据" min-width="120" align="center">
            <template slot-scope="{ row }">
              <div class="agent-metric">
                <div class="metric-main">{{ row.activeCount || '0' }}</div>
                <div class="metric-sub">已激活</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="CDK数据" min-width="120" align="center">
            <template slot-scope="{ row }">
              <div class="agent-metric">
                <div class="metric-main">{{ row.cdkCount || '0' }}</div>
                <div class="metric-sub">总数</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="余额" min-width="120" align="center">
            <template slot-scope="{ row }">
              <div class="agent-balance">
                <span class="balance-amount">¥ {{ row.balance || '0.00' }}</span>
                <el-tag
                  v-if="row.balance < 100"
                  size="mini"
                  type="warning"
                  class="balance-warning"
                >
                  余额不足
                </el-tag>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="endDate" label="加入时间" width="120" align="center">
            <template slot-scope="{ row }">
              <div class="join-date">
                {{ formatDate(row.endDate) }}
              </div>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="100" align="center">
            <template slot-scope="{ row }">
              <el-tag
                :type="getStatusType(row.state)"
                size="small"
                effect="dark"
                class="status-tag"
              >
                {{ getStatusText(row.state) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="进度" min-width="140" align="center">
            <template slot-scope="{ row }">
              <div class="progress-cell">
                <el-progress
                  :percentage="row.progress"
                  :stroke-width="6"
                  :show-text="false"
                  :color="getProgressColor(row.progress)"
                />
                <span class="progress-text">{{ row.progress }}%</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" align="center" fixed="right">
            <template slot-scope="{ row }">
              <el-button
                type="text"
                size="small"
                icon="el-icon-view"
                @click="viewAgent(row)"
              >
                查看
              </el-button>
              <el-button
                type="text"
                size="small"
                icon="el-icon-edit"
                @click="editAgent(row)"
              >
                编辑
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <!-- 快速操作 -->
    <div class="quick-actions">
      <h3>快速操作</h3>
      <div class="action-buttons">
        <el-button type="primary" icon="el-icon-plus" class="action-btn">
          生成CDK
        </el-button>
        <el-button type="success" icon="el-icon-refresh" class="action-btn">
          刷新数据
        </el-button>
        <el-button type="info" icon="el-icon-download" class="action-btn">
          导出报表
        </el-button>
        <el-button type="warning" icon="el-icon-setting" class="action-btn">
          系统设置
        </el-button>
      </div>
    </div>
  </div>
</template>

<script>
import * as echarts from "echarts";

export default {
  name: "DashboardWorkplace",
  data() {
    return {
      searchText: '',
      chartRange: '7d',
      statistics: {},
      lineChart: null,
      metrics: [
        {
          label: "昨日激活数(A)",
          value: "9,143",
          percent: 68,
          trend: 12.5,
          icon: "el-icon-date"
        },
        {
          label: "今日激活数(A)",
          value: "4,348",
          percent: 40,
          trend: -5.2,
          icon: "el-icon-sunny"
        },
        {
          label: "昨日激活数(C)",
          value: "1,343",
          percent: 70,
          trend: 8.3,
          icon: "el-icon-monitor"
        },
        {
          label: "今日激活数(C)",
          value: "658",
          percent: 45,
          trend: -3.7,
          icon: "el-icon-cpu"
        },
        {
          label: "CDK生成量",
          value: "2,489",
          percent: 82,
          trend: 15.8,
          icon: "el-icon-document-add"
        }
      ],
      lineChartData: {
        xAxis: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"],
        series: [120, 200, 150, 80, 70, 110, 130],
      },
      agents: [
        {
          id: 1001,
          projectName: "lixiao",
          state: 0,
          startDate: "2024-03-01",
          endDate: "2024-06-01",
          progress: 30,
          activeCount: 1500,
          cdkCount: 2000,
          balance: 2850.50
        },
        {
          id: 1002,
          projectName: "wangzhang",
          state: 0,
          startDate: "2024-03-01",
          endDate: "2024-08-01",
          progress: 10,
          activeCount: 450,
          cdkCount: 800,
          balance: 1200.00
        },
        {
          id: 1003,
          projectName: "xiaoll",
          state: 1,
          startDate: "2024-01-01",
          endDate: "2024-05-01",
          progress: 60,
          activeCount: 3200,
          cdkCount: 5000,
          balance: 5680.75
        },
        {
          id: 1004,
          projectName: "wuli",
          state: 1,
          startDate: "2024-06-01",
          endDate: "2024-10-01",
          progress: 0,
          activeCount: 0,
          cdkCount: 100,
          balance: 85.50
        },
        {
          id: 1005,
          projectName: "shitou",
          state: 2,
          startDate: "2024-01-01",
          endDate: "2024-09-01",
          progress: 100,
          activeCount: 5800,
          cdkCount: 6000,
          balance: 9850.00
        },
        {
          id: 1006,
          projectName: "mini",
          state: 3,
          startDate: "2024-02-01",
          endDate: "2024-10-01",
          progress: 100,
          activeCount: 4200,
          cdkCount: 4500,
          balance: 7200.25
        },
        {
          id: 1007,
          projectName: "skyy",
          state: 3,
          startDate: "2024-01-01",
          endDate: "2024-03-01",
          progress: 100,
          activeCount: 1800,
          cdkCount: 2000,
          balance: 3200.00
        },
      ],
    };
  },
  computed: {
    loginUser() {
      return this.$store.state.user.user || { nickname: '管理员' };
    },
    filteredAgents() {
      if (!this.searchText) return this.agents;
      return this.agents.filter(agent =>
        agent.projectName.toLowerCase().includes(this.searchText.toLowerCase())
      );
    }
  },
  mounted() {
    this.initChart();
    window.addEventListener("resize", this.resizeChart);
    this.getStatistics();
  },
  beforeUnmount() {
    window.removeEventListener("resize", this.resizeChart);
    this.lineChart && this.lineChart.dispose();
  },
  methods: {
    formatNumber(num) {
      if (num === undefined || num === null) return "0";
      return num.toLocaleString('en-US');
    },

    formatDate(date) {
      if (!date) return '-';
      try {
        return date;
      } catch {
        return date;
      }
    },

    getMetricColor(index) {
      const colors = [
        { bg: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', text: '#fff' },
        { bg: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', text: '#fff' },
        { bg: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)', text: '#fff' },
        { bg: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)', text: '#fff' },
        { bg: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)', text: '#fff' }
      ];
      return {
        background: colors[index % colors.length].bg,
        color: colors[index % colors.length].text
      };
    },

    getProgressColor(percent) {
      if (percent >= 80) return '#52c41a';
      if (percent >= 60) return '#1890ff';
      if (percent >= 40) return '#faad14';
      return '#ff4d4f';
    },

    getStatusType(state) {
      const types = ['success', 'warning', 'danger', 'info'];
      return types[state] || 'info';
    },

    getStatusText(state) {
      const texts = ['活跃', '待审核', '已停用', '正常'];
      return texts[state] || '未知';
    },

    getAgentAvatar(name) {
      // 根据名称生成头像颜色
      const colors = ['#667eea', '#764ba2', '#f5576c', '#4facfe', '#43e97b', '#fa709a'];
      let hash = 0;
      for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
      }
      const index = Math.abs(hash) % colors.length;
      return `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><rect width="100" height="100" fill="${colors[index]}"/><text x="50" y="50" font-family="Arial" font-size="40" fill="white" text-anchor="middle" dy=".3em">${name.charAt(0).toUpperCase()}</text></svg>`;
    },

    viewAgent(agent) {
      this.$message.info(`查看代理: ${agent.projectName}`);
    },

    editAgent(agent) {
      this.$message.info(`编辑代理: ${agent.projectName}`);
    },

    initChart() {
      this.lineChart = echarts.init(this.$refs.lineChart);

      const option = {
        tooltip: {
          trigger: 'axis',
          backgroundColor: 'rgba(255, 255, 255, 0.95)',
          borderColor: '#eee',
          borderWidth: 1,
          textStyle: { color: '#333' },
          formatter: '{b}: {c} 次'
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          top: '10%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: this.lineChartData.xAxis,
          axisLine: { lineStyle: { color: '#e8e8e8' } },
          axisTick: { show: false },
          axisLabel: { color: '#666' }
        },
        yAxis: {
          type: 'value',
          axisLine: { show: false },
          axisTick: { show: false },
          axisLabel: { color: '#666' },
          splitLine: { lineStyle: { color: '#f5f5f5', type: 'dashed' } }
        },
        series: [
          {
            name: '激活用户',
            type: 'line',
            smooth: true,
            symbol: 'circle',
            symbolSize: 8,
            lineStyle: {
              width: 3,
              color: '#36c'
            },
            itemStyle: {
              color: '#36c',
              borderColor: '#fff',
              borderWidth: 2
            },
            areaStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: 'rgba(54, 204, 204, 0.3)' },
                { offset: 1, color: 'rgba(54, 204, 204, 0.05)' }
              ])
            },
            data: this.lineChartData.series
          }
        ]
      };

      this.lineChart.setOption(option);
    },

    resizeChart() {
      this.lineChart && this.lineChart.resize();
    },

    getStatistics() {
      this.$http.get('/home/statistics').then(res => {
        if (res.data.code === 200) {
          this.statistics = res.data.data;
        } else {
          this.$message.error(res.data.msg);
        }
      }).catch(e => {
        this.$message.error(e.message);
      });
    }
  }
};
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

/* 顶部欢迎卡片 */
.welcome-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  color: white;
  margin-bottom: 24px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.2);
}

.welcome-content {
  padding: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.user-avatar {
  border: 4px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.user-details {
  flex: 1;
}

.welcome-title {
  font-size: 28px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: white;
}

.welcome-subtitle {
  font-size: 16px;
  opacity: 0.9;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.stats-cards {
  display: flex;
  gap: 24px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 20px;
  min-width: 180px;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.stat-icon {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  font-size: 24px;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 8px;
}

.stat-total {
  font-size: 12px;
  opacity: 0.7;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding-top: 8px;
}

/* 核心指标网格 */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.metric-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.metric-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.metric-icon {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}

.metric-title {
  font-size: 16px;
  font-weight: 500;
  flex: 1;
}

.metric-value {
  font-size: 36px;
  font-weight: 700;
  margin-bottom: 16px;
}

.metric-progress {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.metric-progress ::v-deep .el-progress-bar {
  flex: 1;
}

.metric-percent {
  font-size: 14px;
  font-weight: 600;
  min-width: 50px;
  text-align: right;
}

.metric-trend {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
}

.trend-value {
  font-weight: 600;
}

.trend-value.up {
  color: #52c41a;
}

.trend-value.down {
  color: #ff4d4f;
}

.trend-label {
  opacity: 0.7;
}

/* 图表区域 */
.chart-section {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 24px;
  margin-bottom: 24px;
}

.main-chart {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.chart-header h3 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}

.chart-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.chart-container {
  width: 100%;
  height: 300px;
}

/* 目标卡片 */
.goal-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.goal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.goal-header h3 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}

.goal-content {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 24px;
}

.goal-info {
  flex: 1;
}

.goal-current .goal-amount {
  font-size: 32px;
  font-weight: 700;
  color: #36c;
  margin-bottom: 4px;
}

.goal-current .goal-label {
  font-size: 14px;
  color: #666;
}

.goal-target {
  margin-top: 20px;
}

.goal-target-value {
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 4px;
}

.goal-progress {
  font-size: 12px;
  color: #52c41a;
}

.goal-stats {
  display: flex;
  gap: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

.stat-item {
  flex: 1;
  text-align: center;
}

.stat-number {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 4px;
}

.stat-text {
  font-size: 12px;
  color: #999;
}

/* 代理列表 */
.agent-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  margin-bottom: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h3 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.agent-table {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
}

.agent-name {
  display: flex;
  align-items: center;
  gap: 12px;
}

.agent-info {
  line-height: 1.4;
}

.agent-title {
  font-weight: 500;
  margin-bottom: 2px;
}

.agent-id {
  font-size: 12px;
  color: #999;
}

.agent-metric {
  text-align: center;
}

.metric-main {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 2px;
}

.metric-sub {
  font-size: 12px;
  color: #999;
}

.agent-balance {
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
}

.balance-amount {
  font-weight: 600;
  color: #36c;
}

.balance-warning {
  font-size: 11px;
  padding: 1px 6px;
}

.join-date {
  font-size: 14px;
  color: #666;
}

.status-tag {
  min-width: 60px;
  justify-content: center;
}

.progress-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-cell ::v-deep .el-progress-bar {
  flex: 1;
}

.progress-text {
  font-size: 14px;
  font-weight: 500;
  min-width: 40px;
  text-align: right;
}

/* 快速操作 */
.quick-actions {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.quick-actions h3 {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 20px 0;
}

.action-buttons {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.action-btn {
  flex: 1;
  min-width: 120px;
  height: 48px;
  font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .welcome-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 24px;
  }

  .stats-cards {
    width: 100%;
    overflow-x: auto;
    padding-bottom: 10px;
  }

  .chart-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .dashboard-container {
    padding: 12px;
  }

  .welcome-content {
    padding: 20px;
  }

  .welcome-title {
    font-size: 24px;
  }

  .metrics-grid {
    grid-template-columns: 1fr;
  }

  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .header-actions {
    width: 100%;
    justify-content: space-between;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-btn {
    width: 100%;
  }
}

/* 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.welcome-card,
.metric-card,
.main-chart,
.goal-card,
.agent-section,
.quick-actions {
  animation: fadeInUp 0.3s ease-out;
}

/* 滚动条美化 */
.agent-table ::v-deep .el-table__body-wrapper::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.agent-table ::v-deep .el-table__body-wrapper::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.agent-table ::v-deep .el-table__body-wrapper::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.agent-table ::v-deep .el-table__body-wrapper::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
