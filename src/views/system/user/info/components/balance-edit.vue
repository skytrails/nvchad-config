<template>
  <!-- 调整余额对话框 -->
  <el-dialog :visible="visible" title="调整用户余额" width="520px" :destroy-on-close="true" :close-on-click-modal="false"
    class="balance-adjust-dialog">

    <div class="balance-dialog-content">
      <!-- 用户信息卡片 -->
      <el-card shadow="never" class="user-info-card">
        <div class="user-info">
          <circle-avatar :text="form.realname" size="40" class="user-avatar" />
          <div class="user-details">
            <div class="user-name">{{ form.realname || '用户' }}</div>
            <div class="user-id">ID: {{ form.id }}</div>
          </div>
          <div class="current-balance">
            <div class="balance-label">当前余额</div>
            <div class="balance-value">¥ {{ formatCurrency(currentBalance) }}</div>
          </div>
        </div>
      </el-card>

      <!-- 调整表单 -->
      <el-form ref="balanceForm" :model="balanceForm" :rules="balanceRules" label-width="90px" class="balance-form">
        <!-- 调整类型 -->
        <el-form-item label="调整类型:" prop="changeType">
          <el-radio-group v-model="balanceForm.changeType" class="type-radio-group">
            <el-radio-button :label="1" class="type-radio recharge-radio">
              <i class="el-icon-circle-plus-outline"></i>
              <span>充值</span>
            </el-radio-button>
            <el-radio-button :label="2" class="type-radio consume-radio">
              <i class="el-icon-circle-minus"></i>
              <span>消费</span>
            </el-radio-button>
            <el-radio-button :label="3" class="type-radio adjust-radio">
              <i class="el-icon-edit"></i>
              <span>手动调整</span>
            </el-radio-button>
          </el-radio-group>
        </el-form-item>

        <!-- 调整金额 -->
        <el-form-item label="调整金额:" prop="changeAmount" class="amount-form-item">
          <div class="amount-input-wrapper">
            <div class="currency-symbol">¥</div>
            <el-input v-model="balanceForm.changeAmount" placeholder="请输入调整金额" type="number" :min="0.01" :step="0.01"
              @input="handleAmountInput" class="amount-input" ref="amountInput">
              <template slot="append">
                <span class="amount-unit">元</span>
              </template>
            </el-input>
          </div>

          <!-- 快速金额按钮 -->
          <div class="quick-amount-section">
            <div class="quick-amount-title">
              <i class="el-icon-thumb"></i>
              <span>快速金额</span>
            </div>
            <div class="quick-amount-buttons">
              <template v-for="amount in quickAmounts[balanceForm.changeType]">
                <el-button :key="amount" size="mini" :type="balanceForm.changeAmount == amount ? 'primary' : 'default'"
                  :class="['quick-amount-btn', { 'active': balanceForm.changeAmount == amount }]"
                  @click="setQuickAmount(amount)">
                  {{ amount > 0 ? '+' : '' }}{{ formatQuickAmount(amount) }}
                </el-button>
              </template>
            </div>

            <!-- 自定义金额 -->
            <div class="custom-amount">
              <el-input-number v-model="customAmount" :min="0.01" :max="10000" :step="100" :precision="2" size="small"
                placeholder="自定义" class="custom-input" @change="setCustomAmount">
                <template slot="append">元</template>
              </el-input-number>
            </div>
          </div>

          <!-- 预览调整效果 -->
          <div v-if="balanceForm.changeAmount" class="amount-preview">
            <div class="preview-item">
              <span class="preview-label">调整后余额:</span>
              <span class="preview-value" :class="getPreviewBalanceClass()">
                ¥ {{ formatCurrency(calculateNewBalance()) }}
              </span>
            </div>
            <div v-if="Math.abs(balanceForm.changeAmount) >= 1000" class="preview-tips">
              <i class="el-icon-warning"></i>
              <span>调整金额较大，请确认操作</span>
            </div>
          </div>
        </el-form-item>

        <!-- 备注信息 -->
        <el-form-item label="备注说明:" prop="remark">
          <el-input v-model="balanceForm.remark" type="textarea" :rows="3" placeholder="请输入调整原因或备注信息" maxlength="200"
            show-word-limit resize="none" class="remark-textarea">
          </el-input>

          <!-- 常用备注 -->
          <div v-if="balanceForm.changeType === 1" class="quick-remark">
            <div class="quick-remark-title">常用备注：</div>
            <div class="quick-remark-buttons">
              <el-tag v-for="remark in quickRemarks[balanceForm.changeType]" :key="remark" size="small"
                :class="{ 'active': balanceForm.remark === remark }" @click="setQuickRemark(remark)" class="remark-tag">
                {{ remark }}
              </el-tag>
            </div>
          </div>
        </el-form-item>
      </el-form>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="updateVisible(false)" size="medium" class="cancel-btn">
          取消
        </el-button>
        <el-button type="primary" :loading="balanceSubmitLoading" @click="submitBalanceChange" size="medium"
          class="submit-btn" :disabled="!balanceForm.changeAmount">
          <i class="el-icon-check"></i>
          {{ getSubmitButtonText() }}
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script>
import CircleAvatar from '@/components/CircleAvatar.vue';

export default {
  name: 'SystemUserInfo',
  components: { CircleAvatar },
  props: {
    visible: Boolean,
    data: Object,
  },
  data() {
    return {
      // ... 其他数据保持不变 ...
      form: Object.assign({ status: 1 }, this.data),

      // 余额相关数据
      balanceSubmitLoading: false,
      balanceForm: {
        userId: null,
        changeType: 1,
        changeAmount: null,
        remark: ''
      },

      // 快速金额配置
      quickAmounts: {
        1: [10, 50, 100, 200, 500, 1000],  // 充值
        2: [-10, -50, -100, -200, -500],   // 消费
        3: [100, -100, 500, -500, 1000, -1000] // 手动调整
      },

      // 常用备注
      quickRemarks: {
        1: ['用户主动充值', '活动奖励', '客服补发', '系统赠送'],
        2: ['购买商品', '服务消费', '会员续费', '手续费'],
        3: ['系统调整', '数据修正', '补偿调整', '错误修复']
      },

      // 自定义金额
      customAmount: null
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data)
      } else {
        this.form = { status: 1 };
        this.isUpdate = false;
      }
    },
  },
  methods: {
    /* 显示余额调整对话框 */
    showBalanceDialog() {
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

      this.customAmount = null;
      this.updateVisible(true)

      // 自动聚焦金额输入框
      this.$nextTick(() => {
        if (this.$refs.amountInput) {
          this.$refs.amountInput.focus();
        }
        if (this.$refs.balanceForm) {
          this.$refs.balanceForm.clearValidate();
        }
      });
    },

    /* 设置快速金额 */
    setQuickAmount(amount) {
      this.balanceForm.changeAmount = Math.abs(amount);

      // 如果是消费类型，确保金额为负
      if (this.balanceForm.changeType === 2 && amount > 0) {
        this.balanceForm.changeAmount = -amount;
      }

      // 触发验证
      this.$refs.balanceForm.validateField('changeAmount');
    },

    /* 设置自定义金额 */
    setCustomAmount(value) {
      if (value) {
        this.balanceForm.changeAmount = value;
        if (this.balanceForm.changeType === 2) {
          this.balanceForm.changeAmount = -value;
        }
      }
    },

    /* 设置快速备注 */
    setQuickRemark(remark) {
      this.balanceForm.remark = remark;
    },

    /* 格式化快速金额显示 */
    formatQuickAmount(amount) {
      if (amount >= 1000) {
        return (amount / 1000).toFixed(1) + 'K';
      }
      return amount.toString();
    },

    /* 金额输入处理 */
    handleAmountInput(value) {
      // 限制最多两位小数
      if (value.includes('.')) {
        const parts = value.split('.');
        if (parts[1].length > 2) {
          this.balanceForm.changeAmount = parseFloat(value).toFixed(2);
        }
      }

      // 根据类型处理正负号
      if (this.balanceForm.changeType === 2 && value > 0) {
        this.balanceForm.changeAmount = -Math.abs(value);
      }
    },

    /* 计算新余额 */
    calculateNewBalance() {
      if (!this.balanceForm.changeAmount) return this.currentBalance;

      let changeAmount = Number(this.balanceForm.changeAmount);

      // 如果是消费类型且输入正数，转为负数
      if (this.balanceForm.changeType === 2 && changeAmount > 0) {
        changeAmount = -changeAmount;
      }

      return this.currentBalance + changeAmount;
    },

    /* 获取预览余额的样式类 */
    getPreviewBalanceClass() {
      const newBalance = this.calculateNewBalance();
      if (newBalance < 0) {
        return 'balance-negative';
      } else if (newBalance > this.currentBalance) {
        return 'balance-positive';
      } else if (newBalance < this.currentBalance) {
        return 'balance-decrease';
      }
      return '';
    },
    updateVisible(value) {
      this.$emit("update:visible", value);
    },

    /* 获取提交按钮文本 */
    getSubmitButtonText() {
      if (this.balanceSubmitLoading) {
        return '处理中...';
      }

      const amount = this.balanceForm.changeAmount;
      if (!amount) return '确认调整';

      const absAmount = Math.abs(amount);
      const typeText = {
        1: '充值',
        2: '消费',
        3: '调整'
      }[this.balanceForm.changeType] || '调整';

      return `确认${typeText} ¥${this.formatCurrency(absAmount)}`;
    },

    /* 提交余额调整 */
    async submitBalanceChange() {
      try {
        const valid = await this.$refs.balanceForm.validate();
        if (!valid) return;

        // 确认提示
        const amount = Math.abs(this.balanceForm.changeAmount);
        const typeText = {
          1: '充值',
          2: '消费',
          3: '手动调整'
        }[this.balanceForm.changeType];

        const confirmMessage = `
          <div class="confirm-message">
            <p>确定要执行以下操作吗？</p>
            <p class="confirm-detail">
              <strong>操作类型：</strong>${typeText}<br>
              <strong>操作金额：</strong>¥ ${this.formatCurrency(amount)}<br>
              <strong>当前余额：</strong>¥ ${this.formatCurrency(this.currentBalance)}<br>
              <strong>调整后余额：</strong>¥ ${this.formatCurrency(this.calculateNewBalance())}
            </p>
            <p class="confirm-warning" v-if="Math.abs(amount) >= 1000">
              <i class="el-icon-warning"></i> 此操作涉及较大金额，请谨慎确认！
            </p>
          </div>
        `;

        await this.$confirm(confirmMessage, '确认调整余额', {
          confirmButtonText: '确认调整',
          cancelButtonText: '再想想',
          type: 'warning',
          dangerouslyUseHTMLString: true,
          customClass: 'balance-confirm-dialog'
        });

        this.balanceSubmitLoading = true;

        // 准备提交数据
        const submitData = {
          ...this.balanceForm,
          // changeAmount: Number(this.balanceForm.changeAmount),
          // 如果是消费类型，确保为负数
          changeAmount: this.balanceForm.changeType === 2 && this.balanceForm.changeAmount > 0
            ? -this.balanceForm.changeAmount
            : this.balanceForm.changeAmount
        };

        const response = await this.$http.post('/asset/balance/adjust', submitData);

        if (response.data.code === 200) {
          this.$message.success({
            message: response.data.message || '余额调整成功',
            type: 'success',
            duration: 2000
          });

          this.updateVisible(false)

          // 刷新数据
          await this.getBalanceLogs();

          // 更新当前余额显示
          if (response.data.data && response.data.data.newBalance) {
            this.currentBalance = response.data.data.newBalance;
            this.form.balance = this.currentBalance;
          }

        } else {
          this.$message.error(response.data.message || '余额调整失败');
        }
      } catch (error) {
        // 用户取消操作
        if (error !== 'cancel') {
          console.error('余额调整失败:', error);
          this.$message.error('余额调整失败：' + (error.message || '网络错误'));
        }
      } finally {
        this.balanceSubmitLoading = false;
      }
    },

    // ... 其他方法保持不变 ...
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
  },
  computed: {
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

  }
};
</script>

<style scoped>
/* 对话框样式 */
.balance-adjust-dialog :deep(.el-dialog) {
  border-radius: 12px;
  overflow: hidden;
}

.balance-adjust-dialog :deep(.el-dialog__header) {
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  padding: 16px 20px;
}

.balance-adjust-dialog :deep(.el-dialog__title) {
  color: white;
  font-size: 16px;
  font-weight: 600;
}

.balance-adjust-dialog :deep(.el-dialog__headerbtn .el-dialog__close) {
  color: white;
}

.balance-adjust-dialog :deep(.el-dialog__body) {
  padding: 0;
}

.balance-dialog-content {
  padding: 20px;
}

/* 用户信息卡片 */
.user-info-card {
  margin-bottom: 20px;
  border: 1px solid #e6ebf5;
  border-radius: 8px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-avatar {
  flex-shrink: 0;
}

.user-details {
  flex: 1;
}

.user-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.user-id {
  font-size: 12px;
  color: #909399;
  background: #f5f7fa;
  padding: 2px 8px;
  border-radius: 10px;
  display: inline-block;
}

.current-balance {
  text-align: right;
  flex-shrink: 0;
}

.balance-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.balance-value {
  font-size: 20px;
  font-weight: 700;
  color: #67c23a;
}

/* 调整类型按钮组 */
.type-radio-group {
  display: flex;
  gap: 8px;
  width: 100%;
}

.type-radio {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.type-radio i {
  font-size: 16px;
}

.type-radio span {
  font-weight: 500;
}

.recharge-radio :deep(.el-radio-button__inner) {
  border-color: #67c23a;
  color: #67c23a;
}

.recharge-radio :deep(.el-radio-button__orig-radio:checked + .el-radio-button__inner) {
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
  border-color: #67c23a;
}

.consume-radio :deep(.el-radio-button__inner) {
  border-color: #f56c6c;
  color: #f56c6c;
}

.consume-radio :deep(.el-radio-button__orig-radio:checked + .el-radio-button__inner) {
  background: linear-gradient(135deg, #f56c6c 0%, #e64242 100%);
  border-color: #f56c6c;
}

.adjust-radio :deep(.el-radio-button__inner) {
  border-color: #409eff;
  color: #409eff;
}

.adjust-radio :deep(.el-radio-button__orig-radio:checked + .el-radio-button__inner) {
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  border-color: #409eff;
}

/* 金额输入区域 */
.amount-form-item {
  margin-bottom: 24px;
}

.amount-input-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}

.currency-symbol {
  font-size: 24px;
  font-weight: 700;
  color: #409eff;
  width: 40px;
  text-align: center;
}

.amount-input {
  flex: 1;
}

.amount-input :deep(.el-input__inner) {
  font-size: 20px;
  font-weight: 600;
  height: 48px;
  text-align: right;
  border-color: #409eff;
}

.amount-unit {
  color: #606266;
  font-weight: 500;
  padding: 0 12px;
}

/* 快速金额区域 */
.quick-amount-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  margin-top: 16px;
}

.quick-amount-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  margin-bottom: 12px;
}

.quick-amount-title i {
  color: #409eff;
}

.quick-amount-buttons {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 12px;
}

.quick-amount-btn {
  height: 36px;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.quick-amount-btn.active {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
}

/* 自定义金额 */
.custom-amount {
  margin-top: 12px;
}

.custom-input {
  width: 150px;
}

.custom-input :deep(.el-input-number__increase),
.custom-input :deep(.el-input-number__decrease) {
  background: #f5f7fa;
}

/* 金额预览 */
.amount-preview {
  background: #f0f9ff;
  border-radius: 8px;
  padding: 12px 16px;
  margin-top: 16px;
  border: 1px solid #d9ecff;
}

.preview-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.preview-label {
  color: #606266;
  font-size: 14px;
}

.preview-value {
  font-size: 18px;
  font-weight: 700;
}

.preview-value.balance-positive {
  color: #67c23a;
}

.preview-value.balance-decrease {
  color: #e6a23c;
}

.preview-value.balance-negative {
  color: #f56c6c;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    opacity: 1;
  }

  50% {
    opacity: 0.7;
  }

  100% {
    opacity: 1;
  }
}

.preview-tips {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #e6a23c;
  font-size: 12px;
  padding-top: 8px;
  border-top: 1px dashed #f0c48a;
}

.preview-tips i {
  font-size: 14px;
}

/* 备注区域 */
.remark-textarea {
  margin-bottom: 12px;
}

.quick-remark {
  margin-top: 12px;
}

.quick-remark-title {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.quick-remark-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.remark-tag {
  cursor: pointer;
  transition: all 0.2s ease;
}

.remark-tag:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.remark-tag.active {
  background: #409eff;
  color: white;
  border-color: #409eff;
}

/* 底部按钮 */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #e6ebf5;
}

.cancel-btn {
  min-width: 80px;
}

.submit-btn {
  min-width: 140px;
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
  border: none;
  font-weight: 500;
}

.submit-btn:hover {
  background: linear-gradient(135deg, #85ce61 0%, #67c23a 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(103, 194, 58, 0.3);
}

.submit-btn:active {
  transform: translateY(0);
}

.submit-btn:disabled {
  background: #c0c4cc;
  transform: none;
  box-shadow: none;
  cursor: not-allowed;
}

/* 响应式调整 */
@media (max-width: 600px) {
  .user-info {
    flex-direction: column;
    text-align: center;
  }

  .current-balance {
    text-align: center;
  }

  .quick-amount-buttons {
    grid-template-columns: repeat(2, 1fr);
  }

  .type-radio-group {
    flex-direction: column;
  }
}
</style>

<style>
/* 全局样式 */
.balance-confirm-dialog .el-message-box__message p {
  margin: 8px 0;
}

.balance-confirm-dialog .confirm-detail {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 6px;
  margin: 12px 0;
  line-height: 1.6;
}

.balance-confirm-dialog .confirm-warning {
  color: #e6a23c;
  font-weight: 500;
  padding: 8px;
  background: #fdf6ec;
  border-radius: 4px;
  margin-top: 12px;
}

.balance-confirm-dialog .confirm-warning i {
  margin-right: 6px;
}
</style>
