<template>
  <div class="ele-body ele-body-card">
    <!-- 顶部卡片 -->
    <el-card shadow="never" body-style="padding: 20px;">
      <div class="ele-cell workplace-user-card">
        <div class="ele-cell-content ele-cell">
          <el-avatar :size="68" :src="require('@/assets/logo.png')" />
          <div class="ele-cell-content">
            <h4 class="ele-elip">
              您好，{{ loginUser.nickname }}，开始您一天的工作吧！
            </h4>
            <div class="ele-text-secondary ele-elip" style="margin-top: 8px">
              <i class="el-icon-heavy-rain"></i>
              <span><s /><s />持续把正确的事情做到位，结果只是时间问题。</span>
            </div>
          </div>
        </div>
        <div class="workplace-count-group">
          <div class="workplace-count-item">
            <div class="workplace-count-header">
              <el-tag size="small" class="ele-tag-round">
                <i class="el-icon-menu"></i>
              </el-tag>
              <span class="workplace-count-name">游戏总数</span>
            </div>
            <div class="workplace-count-num">3721</div>
          </div>
          <div class="workplace-count-item">
            <div class="workplace-count-header">
              <el-tag type="warning" size="small" class="ele-tag-round">
                <i class="el-icon-finished"></i>
              </el-tag>
              <span class="workplace-count-name">总激活数</span>
            </div>
            <div class="workplace-count-num">6 / 24</div>
          </div>
          <div class="workplace-count-item">
            <div class="workplace-count-header">
              <el-tag type="success" size="small" class="ele-tag-round">
                <i class="el-icon-bell"></i>-->
              </el-tag>
              <span class="workplace-count-name">客户端激活数</span>
            </div>
            <div class="workplace-count-num">1,689 / 2,898</div>
          </div>
        </div>
      </div>
    </el-card>
    <!-- 快捷方式 -->
    <template>
      <div class="dashboard-list">
        <el-card v-for="(item, index) in list" :key="index" shadow="hover" class="dashboard-card">
          <div class="app-link-block">
            <el-progress :width="160" :percentage="100" type="circle" show-text="true" :format="() => item.value" />
            <div class="workplace-goal-text">
              {{ item.label }}
            </div>
          </div>
        </el-card>
        <el-card shadow="hover" class="dashboard-chart-card">
          <div class="dashboard-chart-title">
            最近 7 天激活数
          </div>
          <div ref="lineChart" class="dashboard-line-chart"></div>
        </el-card>
      </div>
    </template>

    <!-- 最新动态、我的任务、本月目标 -->
    <el-row :gutter="15">
      <el-col :lg="16" :md="24">
        <el-card shadow="never" header="代理列表" body-style="padding: 12px;" class="workplace-table-card">
          <el-table :data="projectList" height="358">
            <el-table-column type="index" width="35" min-width="35" align="right" />
            <el-table-column label="代理名称" width="150">
              <template slot-scope="{ row }">
                <el-link type="primary" :underline="false">
                  {{ row.projectName }}
                </el-link>
              </template>
            </el-table-column>
            <el-table-column label="激活数" prop="amount" width="95" min-width="80" align="center" />
            <el-table-column label="CDK总数" prop="amount" width="95" min-width="80" align="center" />
            <el-table-column label="余额" prop="amount" width="95" min-width="80" align="center" />
            <el-table-column prop="endDate" label="加入时间" width="95" min-width="80" align="center" />
            <el-table-column label="状态" width="70" min-width="60" align="center">
              <template slot-scope="{ row }">
                <span :class="[
                  'ele-text-success',
                  'ele-text-danger',
                  'ele-text-warning',
                  'ele-text-info ele-text-delete',
                ][row.state]
                  ">
                  {{ ["进行中", "已延期", "未开始", "已结束"][row.state] }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="进度" min-width="100" align="center">
              <template slot-scope="{ row }">
                <el-progress :percentage="row.progress" class="ele-text-small" />
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <el-col :lg="8" :md="12" class="hidden-md-and-down">
        <el-card shadow="never" header="余额">
          <div class="workplace-goal-group">
            <el-progress :width="170" :percentage="80" type="dashboard" :format="() => {
              return '';
            }
              " />
            <div class="workplace-goal-content">
              <el-tag size="large" class="ele-tag-round">
                <i class="el-icon-s-data"></i>
              </el-tag>
              <div class="workplace-goal-num">285</div>
            </div>
            <div class="workplace-goal-text">恭喜，本月目标已达标！</div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import * as echarts from "echarts";
export default {
  name: "DashboardWorkplace",
  data() {
    return {
      list: [
        { percent: 68, value: "9143", label: "昨日激活数(A)" },
        { percent: 40, value: "4348", label: "今日激活数(A)" },
        { percent: 70, value: "1343", label: "昨日激活数(C)" },
        { percent: 70, value: "1343", label: "昨日激活数(C)" },
        { percent: 70, value: "1343", label: "昨日CDK生成" },
      ],
      // 折线图数据
      lineChartData: {
        xAxis: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"],
        series: [120, 200, 150, 80, 70, 110, 130],
      },
      // 项目进度数据
      projectList: [
        {
          projectName: "lixiao",
          state: 0,
          startDate: "2024-03-01",
          endDate: "2024-06-01",
          progress: 30,
        },
        {
          projectName: "wangzhang",
          state: 0,
          startDate: "2024-03-01",
          endDate: "2024-08-01",
          progress: 10,
        },
        {
          projectName: "xiaoll",
          state: 1,
          startDate: "2024-01-01",
          endDate: "2024-05-01",
          progress: 60,
        },
        {
          projectName: "wuli",
          state: 1,
          startDate: "2024-06-01",
          endDate: "2024-10-01",
          progress: 0,
        },
        {
          projectName: "shitou",
          state: 2,
          startDate: "2024-01-01",
          endDate: "2024-09-01",
          progress: 100,
        },
        {
          projectName: "mini",
          state: 3,
          startDate: "2024-02-01",
          endDate: "2024-10-01",
          progress: 100,
        },
        {
          projectName: "skyy",
          state: 3,
          startDate: "2024-01-01",
          endDate: "2024-03-01",
          progress: 100,
        },
      ],
    };
  },
  computed: {
    // 当前登录用户信息
    loginUser() {
      console.log(this.$store.state.fund);
      return this.$store.state.user.user;
    },
  },
  mounted() {
    this.initLineChart();
    window.addEventListener("resize", this.resizeChart);
  },
  beforeUnmount() {
    window.removeEventListener("resize", this.resizeChart);
    this.lineChart && this.lineChart.dispose();
  },
  methods: {
    initLineChart() {
      this.lineChart = echarts.init(this.$refs.lineChart);

      this.lineChart.setOption({
        tooltip: {
          trigger: "axis",
        },
        grid: {
          left: "3%",
          right: "4%",
          bottom: "3%",
          containLabel: true,
        },
        xAxis: {
          type: "category",
          data: this.lineChartData.xAxis,
        },
        yAxis: {
          type: "value",
        },
        series: [
          {
            name: "激活用户",
            type: "line",
            smooth: true,
            areaStyle: {},
            data: this.lineChartData.series,
          },
        ],
      });
    },

    resizeChart() {
      this.lineChart && this.lineChart.resize();
    },
  }
};
</script>

<style scoped>
/* 顶部用户信息卡片 */
.workplace-user-card .ele-cell-content {
  overflow: hidden;
}

.workplace-count-group {
  white-space: nowrap;
}

.workplace-count-item {
  padding: 0 5px 0 25px;
  box-sizing: border-box;
  display: inline-block;
  text-align: right;
}

.workplace-count-name {
  padding-left: 8px;
}

.workplace-count-num {
  font-size: 24px;
  margin-top: 6px;
}

@media screen and (max-width: 992px) {
  .workplace-count-item {
    padding: 0 5px 0 10px;
  }
}

@media screen and (max-width: 768px) {

  .workplace-user-card,
  .workplace-count-group {
    display: block;
  }

  .workplace-count-group {
    margin-top: 15px;
    text-align: right;
  }

  .workplace-user-card ::v-deep .el-avatar {
    width: 45px !important;
    height: 45px !important;
  }

  .workplace-user-card h4 {
    font-size: 16px;
  }

  .workplace-user-card h4+.ele-text-secondary {
    font-size: 12px;
  }

  .workplace-user-card {
    margin: -10px;
  }
}

/* 快捷方式 */
.app-link-block {
  display: block;
  color: inherit;
  padding: 15px 0;
  text-align: center;
  text-decoration: none;
  cursor: pointer;
}

.app-link-block .app-link-icon {
  color: #69c0ff;
  font-size: 30px;
  margin-top: 5px;
}

.app-link-block .app-link-title {
  margin-top: 8px;
}

/* 最新动态时间轴 */
.ele-timeline-act {
  padding-left: 50px;
}

.ele-timeline-act ::v-deep .el-timeline-item__timestamp {
  margin: 0;
  position: absolute;
  top: 3px;
  left: -45px;
}

.ele-timeline-act ::v-deep .el-timeline-item {
  padding-bottom: 19px;
}

.ele-timeline-act ::v-deep .el-timeline-item:last-child {
  padding-bottom: 0;
}

/* 表格 */
.workplace-table-card ::v-deep .el-table tbody>.el-table__row:last-child td {
  border-bottom: none;
}

.workplace-table-card ::v-deep .el-table:before {
  display: none;
}

.workplace-table-card .sort-handle {
  cursor: move;
  font-size: 18px;
  vertical-align: middle;
}

.workplace-table-card ::v-deep .el-table__row.sortable-chosen {
  background-color: hsla(0, 0%, 60%, 0.1);
}

.workplace-table-card ::v-deep .el-table__row.sortable-chosen td {
  background-color: transparent;
}

/* 本月目标 */
.workplace-goal-group {
  text-align: center;
  position: relative;
  /*padding: 48px 0;*/
  padding: 80px 0;
}

.workplace-goal-group .workplace-goal-content {
  position: absolute;
  top: 90px;
  left: 0;
  width: 100%;
}

.workplace-goal-group .workplace-goal-num {
  font-size: 40px;
  margin-top: 15px;
}

/* 小组成员 */
.user-list-item {
  padding: 13px 18px;
}

.user-list-item+.user-list-item {
  border-top: 1px solid hsla(0, 0%, 60%, 0.15);
}

.user-list-item .ele-cell-desc {
  margin-top: 5px;
}

.dashboard-list {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  align-items: flex-start;
}

.dashboard-list>*:first-child {
  margin-top: 14px;
}

.dashboard-card {
  flex: 1 10 200px;
  /* 最小宽度 200px，自动换行 */
  max-width: 240px;
}

/* 折线图卡片：吃掉剩余空间 */
.dashboard-chart-card {
  flex: 1;
  min-width: 0;
  /* 非常关键，防止溢出 */
  display: flex;
  flex-direction: column;
}

.dashboard-chart-title {
  font-size: 16px;
  font-weight: 500;
  margin-bottom: 12px;
}

.dashboard-line-chart {
  width: 100%;
  height: 180px;
  /* 必须有高度 */
}

/* 小屏幕优化 */
@media screen and (max-width: 768px) {}
</style>
