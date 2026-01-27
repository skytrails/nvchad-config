<template>
  <!-- 模板部分保持不变 -->
  <div class="ele-body user-profile-container">
    <div class="profile-content">
      <!-- 余额日志表格 -->
      <el-card shadow="never" class="balance-card">
        <div class="card-header">
          <div class="header-title">
            <i class="el-icon-s-finance header-icon"></i>
            <span>余额变更记录</span>
          </div>
          <div class="header-actions">
            <el-button size="small" type="primary" @click="showBalanceDialog" class="add-balance-btn">
              <i class="el-icon-plus"></i>
              调整余额
            </el-button>
            <el-button size="small" @click="refreshBalanceLog" :loading="balanceLoading">
              <i class="el-icon-refresh"></i>
              刷新
            </el-button>
          </div>
        </div>

        <!-- 余额统计 -->
        <div class="balance-summary">
          <div class="balance-item current-balance">
            <div class="balance-label">
              <i class="el-icon-wallet"></i>
              当前余额
            </div>
            <div class="balance-value">
              ¥ <span class="balance-amount">{{ formatCurrency(currentBalance) }}</span>
            </div>
          </div>
          <div class="balance-item total-recharge">
            <div class="balance-label">
              <i class="el-icon-s-marketing"></i>
              累计充值
            </div>
            <div class="balance-value">
              ¥ <span class="balance-amount">{{ formatCurrency(totalRecharge) }}</span>
            </div>
          </div>
          <div class="balance-item total-consume">
            <div class="balance-label">
              <i class="el-icon-shopping-cart-full"></i>
              累计消费
            </div>
            <div class="balance-value">
              ¥ <span class="balance-amount">{{ formatCurrency(totalConsume) }}</span>
            </div>
          </div>
        </div>

        <!-- 余额表格 -->
        <el-table :data="balanceLogs" v-loading="balanceLoading" style="width: 100%" class="balance-table"
          :header-cell-style="{ background: '#f8f9fa', color: '#495057' }">
          <el-table-column prop="changeTime" label="变更时间" width="180" align="center">
            <template v-slot="{ row }">
              <div class="time-cell">
                <div class="date">{{ formatDate(row.createdAt, 'date') }}</div>
                <div class="time">{{ formatDate(row.createdAt, 'time') }}</div>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="changeType" label="变更类型" width="120" align="center">
            <template v-slot="{ row }">
              <el-tag :type="getChangeTypeTag(row.type)" size="small" effect="light">
                {{ getChangeTypeText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>

          <el-table-column prop="changeAmount" label="变更金额" width="120" align="right">
            <template v-slot="{ row }">
              <span :class="{
                'amount-positive': row.amount > 0,
                'amount-negative': row.amount < 0
              }">
                {{ row.amount > 0 ? '+' : '' }}{{ formatCurrency(row.amount) }}
              </span>
            </template>
          </el-table-column>

          <el-table-column prop="balanceAfter" label="变更后余额" width="120" align="right">
            <template v-slot="{ row }">
              <span class="balance-after">
                {{ formatCurrency(row.amountAfter) }}
              </span>
            </template>
          </el-table-column>

          <el-table-column prop="operator" label="操作人" width="120" align="center">
            <template v-slot="{ row }">
              <div class="operator-cell">
                <circle-avatar :text="row.orderNo" size="24" />
                <span class="operator-name">{{ row.adminId || '-' }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="remark" label="备注说明" min-width="200" show-overflow-tooltip>
            <template v-slot="{ row }">
              <div class="remark-cell">
                {{ row.description || '无备注' }}
              </div>
            </template>
          </el-table-column>

          <el-table-column label="操作" width="80" align="center" fixed="right">
            <template v-slot="{ row }">
              <el-button type="text" size="small" @click="viewDetail(row)" class="detail-btn">
                详情
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination :current-page="balanceQuery.page" :page-size="balanceQuery.size" :total="balanceTotal"
            :page-sizes="[10, 20, 50, 100]" layout="total, sizes, prev, pager, next, jumper" background
            @size-change="handleSizeChange" @current-change="handleCurrentChange" />
        </div>
      </el-card>
    </div>

    <balance-edit :visible.sync="balanceDialogVisible" :data="balanceData" />
  </div>
</template>

<script>
import CircleAvatar from '@/components/CircleAvatar.vue';
import { setPageTab } from '@/utils/page-tab-util';
import BalanceEdit from './components/balance-edit.vue';

export default {
  name: 'SystemUserInfo',
  components: { CircleAvatar, BalanceEdit },
  data() {
    return {
      balanceData: {},
      form: {},
      activeTab: 'basic',
      loading: false,
      isUpdate: false,
      roleList: [],
      levelList: [],
      positionList: [],
      deptList: [],
      deptTree: [],
      deptProps: {
        value: 'id',
        label: 'name',
        children: 'children',
        checkStrictly: true
      },

      // 余额相关数据
      balanceDialogVisible: false,
      balanceSubmitLoading: false,
      balanceLoading: false,
      balanceLogs: [],
      balanceTotal: 0,
      currentBalance: 0,
      totalRecharge: 0,
      totalConsume: 0,
      balanceQuery: {
        page: 1,
        size: 10,
        userId: null,
        startTime: null,  // 可选：开始时间
        endTime: null,    // 可选：结束时间
        changeType: null  // 可选：变更类型筛选
      },
      balanceForm: {
        userId: null,
        changeType: 1,
        changeAmount: null,
        remark: ''
      }
    };
  },
  computed: {
    // ... computed部分保持不变 ...
    // 本地验证规则
    localValidate() {
      return {
        email: /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
        phone: /^1[3-9]\d{9}$/
      };
    },

    // 验证规则
    rules() {
      return {
        realname: [
          { required: true, message: '请输入用户姓名', trigger: 'blur' }
        ],
        nickname: [
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ],
        gender: [
          { required: true, message: '请选择性别', trigger: 'blur' }
        ],
        birthday: [
          { required: true, message: '请选择出生日期', trigger: 'blur' }
        ],
        email: [
          { pattern: this.localValidate.email, message: '邮箱格式不正确', trigger: 'blur' }
        ],
        mobile: [
          { pattern: this.localValidate.phone, message: '手机号格式不正确', trigger: 'blur' }
        ]
      };
    },

    workRules() {
      return {
        levelId: [
          { required: true, message: '请选择职级', trigger: 'blur' }
        ],
        positionId: [
          { required: true, message: '请选择岗位', trigger: 'blur' }
        ],
        deptId: [
          { required: true, message: '请选择部门', trigger: 'blur' }
        ],
        status: [
          { required: true, message: '请选择状态', trigger: 'blur' }
        ],
        sort: [
          { required: true, message: '请输入排序号', trigger: 'blur' }
        ],
        roleIds: [
          { required: true, message: '请选择角色', trigger: 'blur' }
        ]
      };
    },

    balanceRules() {
      return {
        changeType: [
          { required: true, message: '请选择调整类型', trigger: 'blur' }
        ],
        changeAmount: [
          { required: true, message: '请输入调整金额', trigger: 'blur' },
          {
            validator: (rule, value, callback) => {
              if (value <= 0) {
                callback(new Error('调整金额必须大于0'));
              } else {
                callback();
              }
            },
            trigger: 'blur'
          }
        ]
      };
    },

    levelName() {
      if (!this.form.levelId) return '';
      const level = this.levelList.find(item => item.id === this.form.levelId);
      return level ? level.name : '';
    },

    positionName() {
      if (!this.form.positionId) return '';
      const position = this.positionList.find(item => item.id === this.form.positionId);
      return position ? position.name : '';
    }
  },
  mounted() {
    const userId = this.$route.query.id;
    this.query(userId);
  },
  methods: {
    /* 查询用户信息 */
    query(id) {
      if (!id) return;

      this.loading = true;
      this.balanceQuery.userId = id;
      this.balanceForm.userId = id;

      Promise.all([
        this.$http.get('/asset/info/' + id).then(userRes => {
          if (userRes.data.code === 200) {
            this.balanceData = userRes.data.data;

            this.currentBalance = this.balanceData.amount || 0;
            this.totalRecharge = this.balanceData.totalRecharge;
            this.totalConsume = this.balanceData.totalConsume;
            this.isUpdate = true;

            setPageTab({
              fullPath: this.$route.fullPath,
              title: this.balanceData.realname + '的详情'
            });
          } else {
            this.$message.error(userRes.data.msg);
          }
        }),
        this.getBalanceLogs()
      ]).then(() => {
        this.loading = false;
      }).catch((e) => {
        this.loading = false;
        this.$message.error(e.message);
      });
    },

    /* 获取余额变更记录 - 真实API */
    async getBalanceLogs() {
      if (!this.balanceQuery.userId) return;

      this.balanceLoading = true;

      try {
        const response = await this.$http.get('/asset/balance/logs', {
          params: {
            id: this.balanceQuery.userId,
            page: this.balanceQuery.page,
            size: this.balanceQuery.size,
            startTime: this.balanceQuery.startTime,
            endTime: this.balanceQuery.endTime,
            changeType: this.balanceQuery.changeType
          }
        });

        if (response.data.code === 200) {
          const result = response.data.data;

          // 假设API返回结构：{ list: [], total: 0, currentBalance: 0, ... }
          this.balanceLogs = result.records || [];
          this.balanceTotal = result.total || 0;

          // 如果没有统计数据，则从列表计算
          // if (result.totalRecharge === undefined || result.totalConsume === undefined) {
          //   this.calculateBalanceStats();
          // }
        } else {
          this.$message.error(response.data.message || '获取余额记录失败');
        }
      } catch (error) {
        console.error('获取余额记录失败:', error);
        this.$message.error('获取余额记录失败：' + (error.message || '网络错误'));
      } finally {
        this.balanceLoading = false;
      }
    },

    /* 获取余额统计数据 - 独立API（可选） */
    async getBalanceStats() {
      if (!this.balanceQuery.userId) return;

      try {
        const response = await this.$http.get(`/asset/info/${this.balanceQuery.userId}`);

        if (response.data.code === 200) {
          const stats = response.data.data;
          this.amount = stats.amount || 0;
          this.totalRecharge = stats.totalRecharge || 0;
          this.totalConsume = stats.totalConsume || 0;
        }
      } catch (error) {
        console.warn('获取余额统计失败，将使用本地计算:', error);
        // 失败时使用本地计算
        this.calculateBalanceStats();
      }
    },

    /* 计算余额统计（备用方案） */
    calculateBalanceStats() {
      // 确保是数组再计算
      if (!Array.isArray(this.balanceLogs)) {
        this.totalRecharge = 0;
        this.totalConsume = 0;
        return;
      }

      this.totalRecharge = this.balanceLogs
        .filter(log => log.changeAmount > 0)
        .reduce((sum, log) => sum + (log.changeAmount || 0), 0);

      this.totalConsume = Math.abs(this.balanceLogs
        .filter(log => log.changeAmount < 0)
        .reduce((sum, log) => sum + (log.changeAmount || 0), 0));
    },

    /* 刷新余额记录 */
    refreshBalanceLog() {
      this.balanceQuery.page = 1; // 重置到第一页
      this.getBalanceLogs();
      this.getBalanceStats() // 如果支持的话
    },

    /* 显示余额调整对话框 */
    showBalanceDialog() {
      // 确保有用户ID
      if (!this.balanceQuery.userId) {
        this.$message.warning('无法获取用户信息');
        return;
      }

      this.balanceForm = {
        userId: this.balanceQuery.userId,
        changeType: 1,
        changeAmount: null,
        remark: ''
      };
      this.balanceDialogVisible = true;

      // 重置表单验证
      this.$nextTick(() => {
        if (this.$refs.balanceForm) {
          this.$refs.balanceForm.clearValidate();
        }
      });
    },

    /* 提交余额调整 - 真实API */
    async submitBalanceChange() {
      try {
        const valid = await this.$refs.balanceForm.validate();
        if (!valid) return;

        this.balanceSubmitLoading = true;

        // 准备提交数据
        const submitData = {
          ...this.balanceForm,
          // 确保金额是数字类型
          changeAmount: Number(this.balanceForm.changeAmount)
        };

        const response = await this.$http.post('/asset/balance/adjust', submitData);

        if (response.data.code === 200) {
          this.$message.success({
            message: response.data.message || '余额调整成功',
            type: 'success',
            duration: 2000
          });

          this.balanceDialogVisible = false;

          // 刷新数据
          await Promise.all([
            this.getBalanceLogs(),
            this.getBalanceStats() // 如果支持的话
          ]);

          // 更新当前余额显示
          if (response.data.data && response.data.data.newBalance) {
            this.currentBalance = response.data.data.newBalance;
            this.form.balance = this.currentBalance;
          }

          // 可选：触发父组件刷新
          this.$emit('balance-updated');

        } else {
          this.$message.error(response.data.message || '余额调整失败');
        }
      } catch (error) {
        console.error('余额调整失败:', error);
        this.$message.error('余额调整失败：' + (error.message || '网络错误'));
      } finally {
        this.balanceSubmitLoading = false;
      }
    },

    /* 查看详情 */
    async viewDetail(row) {
      try {
        // 如果需要查看详细，可以调用详情API
        const response = await this.$http.get(`/asset/balance/detail/${row.id}`);

        if (response.data.code === 200) {
          const detail = response.data.data;

          // 显示详情对话框或弹窗
          this.$alert(`
            <div class="balance-detail">
              <p><strong>变更时间：</strong>${this.formatDate(detail.changeTime)}</p>
              <p><strong>变更类型：</strong>${this.getChangeTypeText(detail.changeType)}</p>
              <p><strong>变更金额：</strong><span class="${detail.changeAmount > 0 ? 'amount-positive' : 'amount-negative'}">${detail.changeAmount > 0 ? '+' : ''}${this.formatCurrency(detail.changeAmount)}</span></p>
              <p><strong>变更前余额：</strong>${this.formatCurrency(detail.balanceBefore)}</p>
              <p><strong>变更后余额：</strong>${this.formatCurrency(detail.balanceAfter)}</p>
              <p><strong>操作人：</strong>${detail.operatorName || '-'}</p>
              <p><strong>备注：</strong>${detail.remark || '无备注'}</p>
              ${detail.orderNo ? `<p><strong>关联订单：</strong>${detail.orderNo}</p>` : ''}
            </div>
          `, '余额变更详情', {
            dangerouslyUseHTMLString: true,
            customClass: 'balance-detail-dialog',
            showConfirmButton: false,
            showCancelButton: true,
            cancelButtonText: '关闭'
          });
        } else {
          this.$message.warning('获取详情失败');
        }
      } catch (error) {
        console.error('获取详情失败:', error);
        this.$message.error('获取详情失败');
      }
    },

    /* 分页处理 */
    handleSizeChange(val) {
      this.balanceQuery.size = val;
      this.balanceQuery.page = 1; // 重置页码
      this.getBalanceLogs();
    },

    handleCurrentChange(val) {
      this.balanceQuery.page = val;
      this.getBalanceLogs();
    },

    /* 获取变更类型文本 - 从字典获取或本地配置 */
    getChangeTypeText(type) {
      // 可以先尝试从本地字典获取
      const localTypes = {
        1: '充值',
        2: '消费',
        3: '手动调整',
        4: '退款',
        5: '奖励',
        6: '系统赠送',
        7: '提现',
        8: '手续费'
      };

      return localTypes[type] || `类型${type}`;
    },

    /* 获取变更类型标签样式 */
    getChangeTypeTag(type) {
      const tags = {
        1: 'success',  // 充值
        2: 'danger',   // 消费
        3: 'info',     // 调整
        4: 'warning',  // 退款
        5: 'primary',  // 奖励
        6: 'success',  // 赠送
        7: 'danger',   // 提现
        8: 'info'      // 手续费
      };
      return tags[type] || 'info';
    },

    /* 格式化金额 - 增强版 */
    formatCurrency(amount) {
      if (amount === null || amount === undefined) return '0.00';

      // 处理字符串数字
      const num = Number(amount);
      if (isNaN(num)) return '0.00';

      // 保留两位小数
      const formatted = num.toFixed(2);

      // 添加千位分隔符
      return formatted.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    },

    /* 格式化日期 - 增强版 */
    formatDate(date, type) {
      if (!date) return '-';

      if (type === 'date') {
        return new Date(date).toLocaleDateString();
      } else if (type === 'time') {
        return new Date(date).toLocaleTimeString();
      }
      return new Date(date).toLocaleString();
    },
  },

  watch: {
    $route() {
      const userId = this.$route.query.id;
      this.query(userId);
    }
  }
};
</script>

<style scoped>
/* 样式保持不变，但可以添加一些新的样式 */
.user-profile-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.page-subtitle {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.profile-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 余额卡片样式 */
.balance-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 0 16px 0;
  border-bottom: 1px solid #f0f0f0;
}

.header-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.header-icon {
  margin-right: 8px;
  color: #409eff;
  font-size: 18px;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.add-balance-btn {
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
  border: none;
}

/* 余额统计 */
.balance-summary {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin: 20px 0;
}

.balance-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  border-left: 4px solid #409eff;
}

.balance-item.total-recharge {
  border-left-color: #67c23a;
}

.balance-item.total-consume {
  border-left-color: #f56c6c;
}

.balance-label {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.balance-label i {
  margin-right: 6px;
  font-size: 16px;
}

.balance-value {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
}

.balance-amount {
  font-size: 24px;
}

/* 余额表格 */
.balance-table {
  margin-top: 16px;
}

.time-cell {
  display: flex;
  flex-direction: column;
}

.date {
  font-weight: 500;
  color: #303133;
}

.time {
  font-size: 12px;
  color: #909399;
}

.amount-positive {
  color: #67c23a;
  font-weight: 500;
}

.amount-negative {
  color: #f56c6c;
  font-weight: 500;
}

.balance-after {
  font-weight: 600;
  color: #409eff;
}

.operator-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.operator-avatar {
  flex-shrink: 0;
}

.operator-name {
  font-size: 14px;
}

.remark-cell {
  color: #606266;
  line-height: 1.5;
}

.detail-btn {
  color: #409eff;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 用户信息卡片样式 */
.profile-card {
  margin-top: 20px;
}

.user-header {
  display: flex;
  gap: 24px;
  padding-bottom: 24px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 24px;
}

.avatar-section {
  flex-shrink: 0;
}

.avatar-wrapper {
  text-align: center;
}

.avatar-preview {
  margin-bottom: 12px;
}

.avatar-placeholder {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 32px;
  font-weight: bold;
}

.avatar-placeholder i {
  font-size: 48px;
  margin-bottom: 4px;
}

.upload-trigger {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #f5f7fa;
  border-radius: 4px;
  color: #606266;
  cursor: pointer;
  transition: all 0.3s;
}

.upload-trigger:hover {
  background: #e4e7ed;
}

.user-summary {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.user-name h3 {
  margin: 0 0 12px 0;
  font-size: 24px;
  color: #303133;
}

.user-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.user-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.stat-item {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.balance-stat {
  color: #67c23a;
  font-weight: 600;
}

/* 选项卡样式 */
.profile-tabs {
  margin-top: 20px;
}

.form-section {
  margin-bottom: 32px;
}

.section-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 16px 0;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.section-title i {
  margin-right: 8px;
  color: #409eff;
}

.compact-form :deep(.el-form-item) {
  margin-bottom: 18px;
}

.phone-prefix {
  padding: 0 12px;
  color: #606266;
}

.email-valid-icon {
  color: #67c23a;
  font-weight: bold;
}

.form-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

/* 状态单选样式 */
.status-form-item :deep(.el-radio-group) {
  display: flex;
  gap: 24px;
}

.status-radio {
  width: 160px;
  height: 80px;
  border-radius: 8px;
  border: 1px solid #dcdfe6;
  padding: 12px;
}

.status-radio :deep(.el-radio__label) {
  padding-left: 0;
}

.status-content {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #909399;
}

.status-radio.status-active .status-dot {
  background-color: #67c23a;
  box-shadow: 0 0 8px rgba(103, 194, 58, 0.3);
}

.status-radio.status-disabled .status-dot {
  background-color: #f56c6c;
  box-shadow: 0 0 8px rgba(245, 108, 108, 0.3);
}

.status-desc {
  font-size: 12px;
  color: #909399;
}

/* 角色选择样式 */
.role-selection-info {
  margin-top: 8px;
}

.selected-count {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #409eff;
  font-weight: 500;
}

.role-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

.selected-roles {
  margin-top: 16px;
}

.roles-title {
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  margin-bottom: 8px;
}

.roles-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.role-tag {
  transition: all 0.3s;
}

.role-tag:hover {
  transform: translateY(-2px);
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f0f0f0;
}

.save-btn {
  min-width: 120px;
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  border: none;
  box-shadow: 0 2px 6px rgba(64, 158, 255, 0.2);
}

.save-btn:hover {
  background: linear-gradient(135deg, #66b1ff 0%, #409eff 100%);
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.3);
}

.reset-btn {
  min-width: 120px;
}

/* 响应式调整 */
@media (max-width: 992px) {
  .user-header {
    flex-direction: column;
    text-align: center;
  }

  .user-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .balance-summary {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .user-stats {
    grid-template-columns: 1fr;
  }

  .status-form-item :deep(.el-radio-group) {
    flex-direction: column;
    gap: 12px;
  }

  .status-radio {
    width: 100%;
  }
}

/* 余额详情弹窗样式（如果需要） */
:deep(.balance-detail-dialog) {
  min-width: 400px;
}

:deep(.balance-detail) {
  line-height: 1.8;
}

:deep(.balance-detail p) {
  margin: 8px 0;
}

:deep(.balance-detail strong) {
  color: #606266;
  min-width: 80px;
  display: inline-block;
}

/* 其他原有样式保持不变 */
</style>
